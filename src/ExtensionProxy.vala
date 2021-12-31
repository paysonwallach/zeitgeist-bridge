/*
 * Copyright (c) 2020 Payson Wallach
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

private class Zeitgeist.Bridge.ExtensionProxy : Object {
    private DataInputStream input_stream;
    private uint8[] message_length_buffer;
    private uint8[] message_content_buffer;
    private size_t message_length;

    public signal void message_received (InsertEventsRequest body);

    public ExtensionProxy () {
        var registry = new Zeitgeist.DataSourceRegistry ();
        var data_source = new Zeitgeist.DataSource.full (
            Config.APPLICATION_ID,
            Config.APPLICATION_NAME, Config.APPLICATION_DESCRIPTION, null);
        registry.register_data_source.begin (data_source);

        var base_input_stream = new UnixInputStream (Posix.STDIN_FILENO, false);
        input_stream = new DataInputStream (base_input_stream);
    }

    private size_t get_message_content_length (uint8[] message_length_buffer) {
        return (
            (message_length_buffer[3] << 24)
            + (message_length_buffer[2] << 16)
            + (message_length_buffer[1] << 8)
            + (message_length_buffer[0]));
    }

    private void message_content_read_cb (Object? object, AsyncResult result) {
        try {
            input_stream.read_async.end (result);

            info (@"received message: $((string) message_content_buffer)");
            var message = Json.gobject_from_data (
                typeof (InsertEventsRequest), ((string) message_content_buffer).make_valid ((ssize_t) message_length)) as InsertEventsRequest;

            message_received (message);

            if (input_stream != null) {
                message_length_buffer = new uint8[4];
                input_stream.read_async.begin (message_length_buffer,
                                               Priority.DEFAULT, null, message_length_read_cb);
            }
        } catch (Error error) {
            warning (error.message);
        }
    }

    private void message_length_read_cb (Object? object, AsyncResult result) {
        try {
            input_stream.read_async.end (result);

            message_length = get_message_content_length (message_length_buffer);
            message_content_buffer = new uint8[message_length];

            info (@"reading message with length $message_length");
            input_stream.read_async.begin (message_content_buffer,
                                           Priority.DEFAULT, null, message_content_read_cb);
        } catch (Error error) {
            warning (error.message);
        }
    }

    public async void begin_listening () {
        info ("beginning listening...");
        message_length_buffer = new uint8[4];

        input_stream.read_async.begin (message_length_buffer,
                                       Priority.DEFAULT, null, message_length_read_cb);
    }

}
