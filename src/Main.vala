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

namespace Zeitgeist.Bridge {
    public static LogWriterOutput log_writer_func (LogLevelFlags log_level, LogField[] fields) {
        if (Environment.get_variable ("G_MESSAGES_DEBUG") != "all" && log_level > LogLevelFlags.LEVEL_MESSAGE)
            return LogWriterOutput.UNHANDLED;

        GLib.Log.writer_journald (log_level, fields);

        return LogWriterOutput.HANDLED;
    }

    public static int main (string[] args) {
        GLib.Log.set_writer_func (Zeitgeist.Bridge.log_writer_func);
        Intl.setlocale ();

        var log = new Zeitgeist.Log ();
        var loop = new MainLoop (null, false);
        var sigterm_source = new Unix.SignalSource (Posix.Signal.TERM);

        sigterm_source.set_callback (() => {
            log.quit.begin ();
            loop.quit ();
            return Source.REMOVE;
        });
        sigterm_source.attach ();

        var extension = new ExtensionProxy ();

        extension.message_received.connect ((body) => {
            var request = body as InsertEventsRequest;

            if (request == null)
                return;

            request.data.events.@foreach ((event) => {
                try {
                    log.insert_event_no_reply (event.to_zeitgeist ());
                } catch (Error err) {
                    warning (err.message);
                }
                info ("inserting event...");
            });
        });
        extension.begin_listening.begin ();

        loop.run ();

        return Posix.EXIT_SUCCESS;
    }

}
