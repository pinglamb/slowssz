# frozen_string_literal: true

class EmptyTestContainer < Slowssz::Container
  fields []
end

class SingleFieldTestContainer < Slowssz::Container
  fields [[:a, Slowssz::Uint8]]
end

class SmallTestContainer < Slowssz::Container
  fields [[:a, Slowssz::Uint16], [:b, Slowssz::Uint16]]
end

def new_bit_vector_from_bytes(size, bytes, bits)
  Slowssz::BitVectorType
    .of(size: size)
    .new([bytes].pack('H*').unpack1('b*').split('').collect { |bool| bool == '1' } + bits)
end

def new_bit_list_from_bytes(limit, bytes, bits)
  Slowssz::BitListType
    .of(limit: limit)
    .new([bytes].pack('H*').unpack1('b*').split('').collect { |bool| bool == '1' } + bits)
end

RSpec.describe Slowssz do
  it 'bool F' do
    expect(Slowssz::Marshal.dump(Slowssz::Boolean.new(false))).to eq(['00'].pack('H*'))
  end

  it 'bool T' do
    expect(Slowssz::Marshal.dump(Slowssz::Boolean.new(true))).to eq(['01'].pack('H*'))
  end

  it 'bitvector TTFTFTFF' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitVectorType.of(size: 8).new([true, true, false, true, false, true, false, false])
      )
    ).to eq(['2b'].pack('H*'))
  end

  it 'bitlist TTFTFTFF' do
    expect(
      Slowssz::Marshal.dump(Slowssz::BitListType.of(limit: 8).new([true, true, false, true, false, true, false, false]))
    ).to eq(['2b01'].pack('H*'))
  end

  it 'bitvector FTFT' do
    expect(Slowssz::Marshal.dump(Slowssz::BitVectorType.of(size: 4).new([false, true, false, true]))).to eq(
      ['0a'].pack('H*')
    )
  end

  it 'bitlist FTFT' do
    expect(Slowssz::Marshal.dump(Slowssz::BitListType.of(limit: 4).new([false, true, false, true]))).to eq(
      ['1a'].pack('H*')
    )
  end

  it 'bitvector FTF' do
    expect(Slowssz::Marshal.dump(Slowssz::BitVectorType.of(size: 3).new([false, true, false]))).to eq(['02'].pack('H*'))
  end

  it 'bitlist FTF' do
    expect(Slowssz::Marshal.dump(Slowssz::BitListType.of(limit: 4).new([false, true, false]))).to eq(['0a'].pack('H*'))
  end

  it 'bitvector TFTFFFTTFT' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitVectorType.of(size: 10).new([true, false, true, false, false, false, true, true, false, true])
      )
    ).to eq(['c502'].pack('H*'))
  end

  it 'bitlist TFTFFFTTFT' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitListType.of(limit: 10).new([true, false, true, false, false, false, true, true, false, true])
      )
    ).to eq(['c506'].pack('H*'))
  end

  it 'bitvector TFTFFFTTFTFFFFTT' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitVectorType
          .of(size: 16)
          .new(
            [true, false, true, false, false, false, true, true, false, true, false, false, false, false, true, true]
          )
      )
    ).to eq(['c5c2'].pack('H*'))
  end

  it 'bitlist TFTFFFTTFTFFFFTT' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::BitListType
          .of(limit: 16)
          .new(
            [true, false, true, false, false, false, true, true, false, true, false, false, false, false, true, true]
          )
      )
    ).to eq(['c5c201'].pack('H*'))
  end

  it 'long bitvector' do
    expect(Slowssz::Marshal.dump(new_bit_vector_from_bytes(512, 'ff' * 64, []))).to eq(['ff' * 64].pack('H*'))
  end

  it 'long bitlist' do
    expect(Slowssz::Marshal.dump(Slowssz::BitListType.of(limit: 512).new([true, true]))).to eq(['07'].pack('H*'))
  end

  it 'long bitlist filled' do
    expect(Slowssz::Marshal.dump(new_bit_list_from_bytes(512, 'ff' * 64, []))).to eq(['ff' * 64 + '01'].pack('H*'))
  end

  it 'odd bitvector filled' do
    expect(Slowssz::Marshal.dump(new_bit_vector_from_bytes(513, 'ff' * 64, [true]))).to eq(
      ['ff' * 64 + '01'].pack('H*')
    )
  end

  it 'odd bitlist filled' do
    expect(Slowssz::Marshal.dump(new_bit_list_from_bytes(513, 'ff' * 64, [true]))).to eq(['ff' * 64 + '03'].pack('H*'))
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

  it 'uint16 list' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::ListType
          .of(type: Slowssz::Uint16, limit: 32)
          .new([Slowssz::Uint16.new(0xaabb), Slowssz::Uint16.new(0xc0ad), Slowssz::Uint16.new(0xeeff)])
      )
    ).to eq(['bbaaadc0ffee'].pack('H*'))
  end

  it 'uint32 list' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::ListType
          .of(type: Slowssz::Uint32, limit: 128)
          .new([Slowssz::Uint32.new(0xaabb), Slowssz::Uint32.new(0xc0ad), Slowssz::Uint32.new(0xeeff)])
      )
    ).to eq(['bbaa0000adc00000ffee0000'].pack('H*'))
  end

  it 'bytes32 list' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::ListType
          .of(type: Slowssz::VectorType.of(type: Slowssz::Uint8, size: 32), limit: 64)
          .new(
            [
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(0xbb), Slowssz::Uint8.new(0xaa)] + [Slowssz::Uint8.new(0x00)] * 30),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(0xad), Slowssz::Uint8.new(0xc0)] + [Slowssz::Uint8.new(0x00)] * 30),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(0xff), Slowssz::Uint8.new(0xee)] + [Slowssz::Uint8.new(0x00)] * 30)
            ]
          )
      )
    ).to eq(
      [
        'bbaa000000000000000000000000000000000000000000000000000000000000' +
          'adc0000000000000000000000000000000000000000000000000000000000000' +
          'ffee000000000000000000000000000000000000000000000000000000000000'
      ].pack('H*')
    )
  end

  it 'bytes32 list long' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::ListType
          .of(type: Slowssz::VectorType.of(type: Slowssz::Uint8, size: 32), limit: 128)
          .new(
            [
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(1)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(2)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(3)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(4)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(5)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(6)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(7)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(8)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(9)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(10)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(11)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(12)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(13)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(14)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(15)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(16)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(17)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(18)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(19)] + [Slowssz::Uint8.new(0x00)] * 31)
            ]
          )
      )
    ).to eq(
      [
        '0100000000000000000000000000000000000000000000000000000000000000' +
          '0200000000000000000000000000000000000000000000000000000000000000' +
          '0300000000000000000000000000000000000000000000000000000000000000' +
          '0400000000000000000000000000000000000000000000000000000000000000' +
          '0500000000000000000000000000000000000000000000000000000000000000' +
          '0600000000000000000000000000000000000000000000000000000000000000' +
          '0700000000000000000000000000000000000000000000000000000000000000' +
          '0800000000000000000000000000000000000000000000000000000000000000' +
          '0900000000000000000000000000000000000000000000000000000000000000' +
          '0a00000000000000000000000000000000000000000000000000000000000000' +
          '0b00000000000000000000000000000000000000000000000000000000000000' +
          '0c00000000000000000000000000000000000000000000000000000000000000' +
          '0d00000000000000000000000000000000000000000000000000000000000000' +
          '0e00000000000000000000000000000000000000000000000000000000000000' +
          '0f00000000000000000000000000000000000000000000000000000000000000' +
          '1000000000000000000000000000000000000000000000000000000000000000' +
          '1100000000000000000000000000000000000000000000000000000000000000' +
          '1200000000000000000000000000000000000000000000000000000000000000' +
          '1300000000000000000000000000000000000000000000000000000000000000'
      ].pack('H*')
    )
  end

  it 'emptyTestStruct' do
    expect(Slowssz::Marshal.dump(EmptyTestContainer.new)).to eq('')
  end

  it 'singleFieldTestStruct' do
    expect(Slowssz::Marshal.dump(SingleFieldTestContainer.new(Slowssz::Uint8.new(0xab)))).to eq(['ab'].pack('H*'))
  end

  it 'small {4567, 0123}' do
    expect(
      Slowssz::Marshal.dump(SmallTestContainer.new(Slowssz::Uint16.new(0x4567), Slowssz::Uint16.new(0x0123)))
    ).to eq(['67452301'].pack('H*'))
  end

  it 'small [4567, 0123]::2' do
    expect(
      Slowssz::Marshal.dump(
        Slowssz::VectorType
          .of(type: Slowssz::Uint16, size: 2)
          .new([Slowssz::Uint16.new(0x4567), Slowssz::Uint16.new(0x0123)])
      )
    ).to eq(['67452301'].pack('H*'))
  end
end
