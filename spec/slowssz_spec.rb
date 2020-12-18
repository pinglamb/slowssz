# frozen_string_literal: true

RSpec.describe Slowssz do
  it 'bool F' do
    expect(Slowssz::Marshal.dump(false)).to eq(['00'].pack('H*'))
  end

  it 'bool T' do
    expect(Slowssz::Marshal.dump(true)).to eq(['01'].pack('H*'))
  end

  it 'bitvector TTFTFTFF' do
    expect(Slowssz::Marshal.dump(Slowssz::BitVector.new([true, true, false, true, false, true, false, false]))).to eq(
      ['2b'].pack('H*')
    )
  end

  it 'bitlist TTFTFTFF' do
    expect(Slowssz::Marshal.dump(Slowssz::BitList.new([true, true, false, true, false, true, false, false], 8))).to eq(
      ['2b01'].pack('H*')
    )
  end

  it 'bitvector FTFT' do
    expect(Slowssz::Marshal.dump(Slowssz::BitVector.new([false, true, false, true]))).to eq(['0a'].pack('H*'))
  end

  it 'bitlist FTFT' do
    expect(Slowssz::Marshal.dump(Slowssz::BitList.new([false, true, false, true], 4))).to eq(['1a'].pack('H*'))
  end

  it 'bitvector FTF' do
    expect(Slowssz::Marshal.dump(Slowssz::BitVector.new([false, true, false]))).to eq(['02'].pack('H*'))
  end

  it 'bitlist FTF' do
    expect(Slowssz::Marshal.dump(Slowssz::BitList.new([false, true, false], 4))).to eq(['0a'].pack('H*'))
  end

  it 'bitvector TFTFFFTTFT' do
    expect(
      Slowssz::Marshal.dump(Slowssz::BitVector.new([true, false, true, false, false, false, true, true, false, true]))
    ).to eq(['c502'].pack('H*'))
  end

  it 'bitlist TFTFFFTTFT' do
    expect(
      Slowssz::Marshal.dump(Slowssz::BitList.new([true, false, true, false, false, false, true, true, false, true], 10))
    ).to eq(['c506'].pack('H*'))
  end

  it 'bitvector TFTFFFTTFTFFFFTT' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitVector.new(
          [true, false, true, false, false, false, true, true, false, true, false, false, false, false, true, true]
        )
      )
    ).to eq(['c5c2'].pack('H*'))
  end

  it 'bitlist TFTFFFTTFTFFFFTT' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitList.new(
          [true, false, true, false, false, false, true, true, false, true, false, false, false, false, true, true],
          16
        )
      )
    ).to eq(['c5c201'].pack('H*'))
  end

  it 'long bitvector' do
    expect(Slowssz::Marshal.dump(new_bit_vector_from_bytes('ff' * 64))).to eq(['ff' * 64].pack('H*'))
  end

  it 'long bitlist' do
    expect(Slowssz::Marshal.dump(Slowssz::BitList.new([true, true], 512))).to eq(['07'].pack('H*'))
  end

  it 'long bitlist filled' do
    expect(Slowssz::Marshal.dump(new_bit_list_from_bytes('ff' * 64, [], 512))).to eq(['ff' * 64 + '01'].pack('H*'))
  end

  it 'odd bitvector filled' do
    expect(Slowssz::Marshal.dump(new_bit_vector_from_bytes('ff' * 64 + '01'))).to eq(['ff' * 64 + '01'].pack('H*'))
  end

  it 'odd bitlist filled' do
    expect(Slowssz::Marshal.dump(new_bit_list_from_bytes('ff' * 64, [true], 513))).to eq(['ff' * 64 + '03'].pack('H*'))
  end

  it 'uint8 00' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint8.new(0x00))).to eq(['00'].pack('H*'))
  end

  it 'uint8 01' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint8.new(0x01))).to eq(['01'].pack('H*'))
  end

  it 'uint8 ab' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint8.new(0xab))).to eq(['ab'].pack('H*'))
  end

  it 'uint16 0000' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint16.new(0x0000))).to eq(['0000'].pack('H*'))
  end

  it 'uint16 abcd' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint16.new(0xabcd))).to eq(['cdab'].pack('H*'))
  end

  it 'uint32 00000000' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint32.new(0x00000000))).to eq(['00000000'].pack('H*'))
  end

  it 'uint32 01234567' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint32.new(0x01234567))).to eq(['67452301'].pack('H*'))
  end

  it 'uint64 0000000000000000' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint64.new(0x0000000000000000))).to eq(['0000000000000000'].pack('H*'))
  end

  it 'uint64 0123456789abcdef' do
    expect(Slowssz::Marshal.dump(Slowssz::Uint64.new(0x0123456789abcdef))).to eq(['efcdab8967452301'].pack('H*'))
  end

  def new_bit_vector_from_bytes(bytes)
    Slowssz::BitVector.new([bytes].pack('H*').unpack1('b*').split('').collect { |bool| bool == '1' })
  end

  def new_bit_list_from_bytes(bytes, bits, capacity)
    Slowssz::BitList.new([bytes].pack('H*').unpack1('b*').split('').collect { |bool| bool == '1' } + bits, capacity)
  end
end
