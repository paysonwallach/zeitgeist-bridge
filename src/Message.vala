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

public class Zeitgeist.Web.Message : Zeitgeist.Web.Serializable {
    public class Data : Zeitgeist.Web.Serializable {
        public string title { get; construct set; }
        public string url { get; construct set; }
        public string mime_type { get; construct set; }
        public int64 access_time { get; construct set; }

        public Data (string title, string url, string mime_type, int64 access_time) {
            Object(
                title: title,
                url: url,
                mime_type: mime_type,
                access_time: access_time);
        }
    }

    public int apiVersion { get; construct set; }
    public string id { get; construct set; }
    public Data data { get; construct set; }

    public Message (int api_version, string id, Data data) {
        Object (
            apiVersion: api_version,
            id: id,
            data: data);
    }
}
