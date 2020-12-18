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
end
