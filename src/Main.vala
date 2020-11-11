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

namespace Zeitgeist.Web {
    public static LogWriterOutput log_writer_func (LogLevelFlags log_level, LogField[] fields) {
        if (log_level > LogLevelFlags.LEVEL_INFO || Environment.get_variable ("G_MESSAGES_DEBUG") == "all")
            return LogWriterOutput.UNHANDLED;

        GLib.Log.writer_journald (log_level, fields);

        return LogWriterOutput.HANDLED;
    }

    private string get_manifestation (string uri) {
        var components = uri.split ("://", 2);

        if (components[0] == "file")
            return uri.substring (0, uri.last_index_of (Path.DIR_SEPARATOR_S) + 1);
        else
            return @"$(components[0])://$(components[1].split (Path.DIR_SEPARATOR_S)[0])/";
    }

    private string get_origin (string uri) {
        var components = uri.split ("://", 2);

        if (components[0] == "file")
            return "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject";
        else if (components[0] == "http" || components[0] == "https")
            return "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#WebDataObject";
        else
            return "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RemoteDataObject";
    }

    public static int main (string[] args) {
        GLib.Log.set_writer_func (Zeitgeist.Web.log_writer_func);
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
            message (@"message received: $(body.data.url)");
            var subject = new Zeitgeist.Subject.full (
                body.data.url,
                "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Website",
                get_manifestation (body.data.url),
                body.data.mime_type,
                get_origin (body.data.url),
                body.data.title,
                "net");
            var event = new Zeitgeist.Event.full (
                "http://www.zeitgeist-project.com/ontologies/2010/01/27/zg#AccessEvent",
                "http://www.zeitgeist-project.com/ontologies/2010/01/27/zg#UserActivity",
                "application://firefox.desktop",
                null,
                subject);
            event.timestamp = body.data.access_time;

            log.insert_event.begin (event);
            message ("inserting event...");
        });
        extension.begin_listening.begin ();

        loop.run ();

        return Posix.EXIT_SUCCESS;
    }

}
