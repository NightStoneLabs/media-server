defmodule MediaServerWeb.Util do
    use Membrane.Pipeline
  
    def get_offset(headers) do
      case List.keyfind(headers, "range", 0) do
        {"range", "bytes=" <> start_pos} ->
          String.split(start_pos, "-") |> hd |> String.to_integer
        nil ->
          0
      end
    end
  
    def get_file_size(path) do
      {:ok, %{size: size}} = File.stat path
  
      size
    end
  
    def send_video(conn, headers, video) do
      video_path = video
      offset = get_offset(headers)
      file_size = get_file_size(video_path)
  
      conn
      |> Plug.Conn.put_resp_header("content-type", "video/mp4")
      |> Plug.Conn.put_resp_header("content-range", "bytes #{offset}-#{file_size-1}/#{file_size}")
      |> Plug.Conn.send_file(206, video_path, offset, file_size - offset)
    end
  end