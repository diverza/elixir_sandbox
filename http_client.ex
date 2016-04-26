defmodule Moon.HttpClient do

  defstruct host: "",
            params: [],
            req_headers: [],
            req_body: ""

  def build_conn(host) do
    %Moon.HttpClient{host: host}
  end

  def add_req_header(conn, {header, value}) do
    %{conn | req_headers: [{header, value}|Map.fetch!(conn, :req_headers)]}
  end

  def put_req_body(conn, :plain, body) do
    %{conn | req_body: body}
  end

  def put_req_body(conn, :json, body) do
    %{conn | req_body: Poison.encode!(body)}
  end

  def add_params(conn, {key, value}) do
    %{conn | params: [{key, value}|Map.fetch!(conn, :params)]}
  end

  def dispatch(conn, method, path) do
    IO.inspect {
      method,
      Map.fetch!(conn, :host) <> path,
      Map.fetch!(conn, :req_body),
      Map.fetch!(conn, :req_headers),
      [{:params, Map.fetch!(conn, :params)}]
    }
    HTTPoison.request!(
      method,
      Map.fetch!(conn, :host) <> path,
      Map.fetch!(conn, :req_body),
      Map.fetch!(conn, :req_headers),
      [{:params, Map.fetch!(conn, :params)}]
    )
  end
end
