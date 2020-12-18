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
end
