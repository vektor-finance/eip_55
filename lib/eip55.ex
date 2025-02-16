defmodule EIP55 do
  @moduledoc """
  Provides EIP-55 encoding and validation functions.
  """

  @doc """
  Encodes an Ethereum address into an EIP-55 checksummed address.

  ## Examples

      iex> EIP55.encode("0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed")
      {:ok, "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"}

      iex> EIP55.encode(<<90, 174, 182, 5, 63, 62, 148, 201, 185, 160,
      ...> 159, 51, 102, 148, 53, 231, 239, 27, 234, 237>>)
      {:ok, "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"}

      iex> EIP55.encode("not an address")
      {:error, :unrecognized_address_format}

  """
  @spec encode(String.t() | binary()) ::
          {:ok, String.t()} | {:error, :unrecognized_address_format}
  def encode("0x" <> address) when byte_size(address) == 40 do
    address = String.downcase(address)

    hash =
      address
      |> ExKeccak.hash_256()
      |> Base.encode16(case: :lower)
      |> String.graphemes()

    encoded =
      address
      |> String.graphemes()
      |> Enum.zip(hash)
      |> Enum.map_join(fn
        {"0", _} -> "0"
        {"1", _} -> "1"
        {"2", _} -> "2"
        {"3", _} -> "3"
        {"4", _} -> "4"
        {"5", _} -> "5"
        {"6", _} -> "6"
        {"7", _} -> "7"
        {"8", _} -> "8"
        {"9", _} -> "9"
        {c, "8"} -> String.upcase(c)
        {c, "9"} -> String.upcase(c)
        {c, "a"} -> String.upcase(c)
        {c, "b"} -> String.upcase(c)
        {c, "c"} -> String.upcase(c)
        {c, "d"} -> String.upcase(c)
        {c, "e"} -> String.upcase(c)
        {c, "f"} -> String.upcase(c)
        {c, _} -> c
      end)

    {:ok, "0x" <> encoded}
  end

  def encode(address) when byte_size(address) == 20 do
    encode("0x" <> Base.encode16(address, case: :lower))
  end

  def encode(_) do
    {:error, :unrecognized_address_format}
  end

  @doc """
  Determines whether the given Ethereum address has a valid EIP-55 checksum.

  ## Examples

      iex> EIP55.valid?("0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed")
      true

      iex> EIP55.valid?("0x5AAEB6053f3e94c9b9a09f33669435e7ef1beaed")
      false

      iex> EIP55.valid?("not an address")
      false
  """
  def valid?("0x" <> _ = address) when byte_size(address) == 42 do
    case encode(address) do
      {:ok, ^address} -> true
      _ -> false
    end
  end

  def valid?(_), do: false
end
