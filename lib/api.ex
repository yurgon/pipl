defmodule Api do
  use HTTPoison.Base

  @endpoint "http://api.pipl.com"

  def search(email, params \\ %{}) do 
    params = params |> Map.merge(%{email: email})
    url = @endpoint <> "/search/?" <> URI.encode_query(params)
    get(url)
  end  

  defp process_response_body(body) do
    body
    |> Poison.decode!
  end

  defp process_request_options(options) do
    [hackney: [:insecure, timeout: 60_000, recv_timeout: 60_000]]
  end

end