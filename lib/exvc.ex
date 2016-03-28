defmodule Exvc do

  def vc_paths() do
    File.ls!("C:\\Program Files (x86)")
    |> Enum.filter(fn(path) -> path |> String.contains?("Microsoft Visual Studio ") end)
  end


  def vc_tools_paths() do
    System.get_env
    |> Map.keys
    |> Enum.filter(fn(key) -> key |> String.contains?("COMNTOOLS") end)
  end


  def vc_versions() do
    vc_paths()
    |> Enum.map(fn(s) -> String.split(s, "Microsoft Visual Studio ", trim: true) end)
    |> List.flatten
    |> Enum.map(fn(s) -> s |> Float.parse end)
    |> Enum.map(fn({v, _}) -> v end)
    |> Enum.sort
  end


  def vc_max_version do
    vc_versions() |> Enum.max
  end


  def vc_path(version \\ vc_max_version()) do
    "Microsoft Visual Studio #{version}"
  end


  def vc_bat_path(path \\ vc_path()) do
    Path.join(["C:", "Program Files (x86)", path, "Common7", "Tools", "VsDevCmd.bat"])
  end


  def vc_varsall_bat_path(path \\ vc_path()) do
    Path.join(["C:", "Program Files (x86)", path, "VC", "vcvarsall.bat"])
  end


  def vc_env_cmd(arch \\ 'amd64') do
    :os.cmd '"call "' ++ String.to_char_list(vc_bat_path) ++ '" & "' ++ String.to_char_list(vc_varsall_bat_path) ++ '" ' ++ arch ++ ' & SET"'
  end


  def vc_env(arch \\ 'amd64') do
    vc_env_cmd(arch)
      |> to_string
      |> String.split("\r\n", trim: true)
      |> Enum.map(fn(x) -> String.split(x, "=", trim: true) end)
      |> Enum.reduce(%{},
        fn
          [k, v], acc -> Map.put(acc, k, v)
          [""], acc -> acc
        end
      )
  end

end
