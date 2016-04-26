defmodule Moon.Sso do
  import Moon.HttpClient

  def authenticate(username, password) do
    hashed_password = hash_password(password)
    build_conn(load_sso_host)
    |> add_req_header({"content-type", "application/json; charset=utf-8"})
    |> put_req_body(:json, %{"hashed_password" => hashed_password, "sign_in_ip" => "127.0.0.1"})
    |> dispatch(:post, "/api/v1/users/#{username}/authenticate")
  end

  def recover_password(mail) do
    build_conn(load_sso_host)
    |> add_req_header({"content-type", "application/json; charset=utf-8"})
    |> add_params({"token", "recover_password"})
    |> dispatch(:get, "/api/v1/users/#{mail}")
  end

  def set_password(token, user_id, password) do
    hashed_password = hash_password(password)
    build_conn(load_sso_host)
    |> add_req_header({"content-type", "application/json; charset=utf-8"})
    |> add_params({"token", token})
    |> put_req_body(:json, %{"hashed_password" => hashed_password})
    |> dispatch(:patch, "/api/v1/users/#{user_id}")
  end

  def change_password(user_id, old_pass, new_pass) do
    new_hashed_pass = hash_password(new_pass)
    old_hashed_pass = hash_password(old_pass)
    build_conn(load_sso_host)
    |> add_req_header({"content-type", "application/json; charset=utf-8"})
    |> add_params({"old_hashed_password", old_hashed_pass})
    |> put_req_body(:json, %{"new_hashed_pass" => new_hashed_pass})
    |> dispatch(:patch, "/api/v1/users/#{user_id}")
  end

  def read_profiles(user_id, client_id) do
    build_conn(load_sso_host)
    |> add_req_header({"content-type", "application/json; charset=utf-8"})
    |> dispatch(:get, "/api/v1/users/#{user_id}/clients/#{client_id}/profiles")
  end

  defp load_sso_host do
    Application.get_env(:phoenix, :env_variables)
    |> Map.fetch!(:sso_address)
  end

  defp hash_password(password) do
    :crypto.hash(:sha512, password)
    |> Base.encode64
  end
end
