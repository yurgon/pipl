defmodule Pipl do

  @test_email "clark.kent@example.com"

  def main(args) do
    args |> parse_args |> process 

  end


  def process(:ok), do: nil
  def process([]), do: IO.puts "No arguments given"
 

  def process(options) do
    key = options[:key]
    csv = File.open!(options[:output], [:write, :utf8])

    if options[:test] do 
      params = %{
        match_requirements: "phone",
        first_name: "Yury",
        last_name: "Chernov"
      } |> Map.merge(%{key: key})
      
      case request(@test_email, params) do
        {:ok, body} ->
          save_response(@test_email, body)

          IO.inspect body
        {:error, reason} -> IO.puts "Error: #{reason}"
        _ -> IO.puts "Error"  
      end
    else
      file = options[:input]
      {:ok, sheet} = Xlsxir.multi_extract(file) |> List.first()
      [headers | rows] = Xlsxir.get_list(sheet)

      for {row, i} <- Enum.with_index(rows) do 
        arr = Enum.zip(headers, row)
        first_name = row_filter("First Name", arr)
        last_name = row_filter("Last Name", arr)
        email = row_filter("Email", arr)
        state = row_filter("State/Province", arr)
        country = row_filter("Country", arr)

        params = %{
          match_requirements: "phone.mobile",
          minimum_match: 1,
          first_name: first_name,
          last_name: last_name,
          raw_address: "#{state} #{country}"
        } |> Map.merge(%{key: key})
        
        #body = File.read!("./tmp/smccurdy@pinnacleliving.com.json") |> Poison.decode!
        #case {:ok, body} do
        case request(email, params) do
          {:ok, body} ->
            save_response(email, body)
            mobile_phones = if body["person"] && body["person"]["phones"]  do 
              phones = body["person"]["phones"] 
              |> Enum.filter(fn x -> x["@type"] == "mobile" end) 
              |> Enum.map(fn x -> x["display_international"] end) 
              |> Enum.join(", ")
  
              [row ++ [phones]] |> CSV.encode |> Enum.each(&IO.write(csv, &1))
              phones
            else
              "Not found"
            end  

            IO.puts "Done: #{first_name} #{last_name} (#{email}) - #{mobile_phones}"
          {:error, reason} -> IO.puts "Error: #{reason}"
          _ -> IO.puts "Error"  
        end        
      end  
    end  
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      aliases: [t: :test, i: :input, o: :output, k: :key, l: :limit],
      switches: [test: :boolean, key: :string, input: :string, output: :string, limit: :integer]
    )
    check_options(options)
  end

  defp check_options(options) do 
    cond do 
      options[:key] == nil -> 
        IO.puts "Please provide an API key"
      options[:input] == nil -> 
        IO.puts "Please provide an Input file"  
      options[:output] == nil -> 
        IO.puts "Please provide an Ounput file"  
      true -> options
    end  
  end  

  defp request(email, params) do 
    case Api.search(email, params) do 
      {:ok, %HTTPoison.Response{body: body}} -> {:ok, body} 
      {:error, %HTTPoison.Error{id: nil, reason: reason}} -> {:error, reason} 
      _ ->  {:error, nil} 
    end  
  end  

  defp save_response(email, body) do 
    unless File.exists?("./tmp"), do: File.mkdir("./tmp") 
    json = Poison.encode!(body)
    File.write!("./tmp/" <> email <> ".json", json)
  end  

  defp row_filter(row, array) do
    case Enum.find(array, fn {k, v} -> k == row end) do
      {row, ""} -> nil
      {row, value} -> value
      _ -> nil
    end
  end
end
