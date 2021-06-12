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
    public class Subject : Serializable {
        [CCode (cname = "currentOrigin")]
        public string? current_origin { get; construct set; }

        [CCode (cname = "currentUri")]
        public string? current_uri { get; construct set; }

        public string? interpretation { get; construct set; }

        public string? manifestation { get; construct set; }

        public string? mimetype { get; construct set; }

        public string? origin { get; construct set; }

        public string? storage { get; construct set; }

        public string? text { get; construct set; }

        public string? uri { get; construct set; }

        public Subject (
                string? current_origin = null, string? current_uri = null,
                string? interpretation = null, string? manifestation = null,
                string? mimetype = null, string? origin = null,
                string? storage = null, string? text = null,
                string? uri = null) {
            this.current_origin = current_origin;
            this.current_uri = current_uri;
            this.interpretation = interpretation;
            this.manifestation = manifestation;
            this.mimetype = mimetype;
            this.origin = origin;
            this.storage = storage;
            this.text = text;
            this.uri = uri;
        }
    }

    public class Event : Serializable {
        public string? actor { get; construct set; }

        public uint32 id { get; construct set; }

        public string? interpretation { get; construct set; }

        public string? manifestation { get; construct set; }

        public string? origin { get; construct set; }

        public ByteArray? payload { get; construct set; }

        public GenericArray<Subject> subjects { get; construct set; }

        public int64 timestamp { get; construct set; }

        public Event (
                string? actor = null, uint32 id = 0,
                string? interpretation = null, string? manifestation = null,
                string? origin = null, ByteArray? payload = null,
                GenericArray<Subject> subjects = new GenericArray<Subject> (),
                int64 timestamp = new DateTime.now_local ().to_unix ()) {
            this.actor = actor;
            this.id = id;
            this.interpretation = interpretation;
            this.manifestation = manifestation;
            this.origin = origin;
            this.payload = payload;
            this.subjects = subjects;
            this.timestamp = timestamp;
        }

        public Event.from_zeitgeist (Zeitgeist.Event event) {
            var subjects = new GenericArray<Subject> ();

            event.subjects.foreach ((subject) => {
                subjects.add(
                    new Subject (
                        subject.current_origin, subject.current_uri,
                        subject.interpretation, subject.manifestation,
                        subject.mimetype, subject.origin, subject.storage,
                        subject.text, subject.uri));
                });

            this (
                event.actor, event.id, event.interpretation,
                event.manifestation, event.origin, event.payload, subjects,
                event.timestamp);
        }

        public Zeitgeist.Event to_zeitgeist () {
            var subjects = new GenericArray<Zeitgeist.Subject> ();
            var event = new Zeitgeist.Event ();

            this.subjects.foreach ((subject) => {
                var _subject = new Zeitgeist.Subject ();

                _subject.current_origin = subject.current_origin;
                _subject.current_uri = subject.current_uri;
                _subject.interpretation = subject.interpretation;
                _subject.manifestation = subject.manifestation;
                _subject.mimetype = subject.mimetype;
                _subject.origin = subject.origin;
                _subject.storage = subject.storage;
                _subject.text = subject.text;
                _subject.uri = subject.uri;

                subjects.add (_subject);
            });

            event.actor = actor;
            event.id = id;
            event.interpretation = interpretation;
            event.manifestation = manifestation;
            event.origin = origin;
            event.subjects = subjects;
            event.timestamp = timestamp;

            return event;
        }

    public void debug_print ()
    {
        warning ("id: %d\t" +
                       "timestamp: %" + int64.FORMAT + "\n" +
                       "actor: %s\n" +
                       "interpretation: %s\n" +
                       "manifestation: %s\n" +
                       "origin: %s\n" +
                       "num subjects: %d\n",
                       id, timestamp, actor, interpretation,
                       manifestation, origin, subjects.length);
        for (int i = 0; i < subjects.length; i++)
        {
            var s = subjects[i];
            warning ("  Subject #%d:\n" +
                           "    uri: %s\n" +
                           "    interpretation: %s\n" +
                           "    manifestation: %s\n" +
                           "    mimetype: %s\n" +
                           "    origin: %s\n" +
                           "    text: %s\n" +
                           "    current_uri: %s\n" +
                           "    current_origin: %s\n" +
                           "    storage: %s\n",
                           i, s.uri, s.interpretation, s.manifestation,
                           s.mimetype, s.origin, s.text, s.current_uri,
                           s.current_origin, s.storage);
        }
        if (payload != null)
            warning ("payload: %u bytes", payload.len);
        else
            warning ("payload: (null)\n");
    }

        public override bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
            if (property_name == "subjects") {
                var subjects = new GenericArray<Subject> ();
                var json_array = property_node.get_array ();

                if (json_array == null)
                    return false;

                json_array.foreach_element ((array, index, element_node) => {
                    subjects.add (
                        Json.gobject_deserialize (
                            typeof (Subject), element_node) as Subject);
                });

                @value = subjects;

                return true;
            }

            return default_deserialize_property (
                property_name, out @value, pspec, property_node);
        }
    }

    public class Message : Serializable {
        [CCode (cname = "apiVersion")]
        public string api_version { get; construct set; }

        public string id { get; construct set; }

        public string? context { get; construct set; }

        public Message (string? context = null) {
            this.api_version = Config.API_VERSION;
            this.id = Uuid.string_random ();
            this.context = context;
        }
    }

    public class InsertEventsRequestData : Serializable {
        public GenericArray<Event> events { get; construct set; }

        public InsertEventsRequestData (GenericArray<Event> events) {
            this.events = events;
        }

        public override bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
            if (property_name == "events") {
                var events = new GenericArray<Event> ();
                var json_array = property_node.get_array ();

                if (json_array == null)
                    return false;

                json_array.foreach_element ((array, index, element_node) => {
                    events.add (
                        Json.gobject_deserialize (
                            typeof (Event), element_node) as Event);
                });

                @value = events;

                return true;
            }

            return default_deserialize_property (
                property_name, out @value, pspec, property_node);
        }
    }

    public class InsertEventsRequest : Message {
        public InsertEventsRequestData data { get; construct set; }

        public InsertEventsRequest (GenericArray<Event> events) {
            this.data = new InsertEventsRequestData (events);
        }

        public InsertEventsRequest.with_event (Zeitgeist.Event event) {
            var events = new GenericArray<Event> ();

            events.add (new Event.from_zeitgeist (event));
            this (events);
        }
    }
}
