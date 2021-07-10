# frozen_string_literal: true

describe BehaviorTree::Nop do
  let(:necessary_ticks) { 1 }
  subject { described_class.new(necessary_ticks) }
  it { is_expected.to be_a BehaviorTree::Task }

  context 'necessary ticks is 0' do
    let(:necessary_ticks) { 0 }
    it { expect { subject }.to raise_error ArgumentError }
  end

  describe '.tick!' do
    context 'necessary ticks is 2' do
      let(:necessary_ticks) { 2 }

      context 'no ticks yet' do
        it 'has node default status' do
          is_expected.to be_success
        end
      end

      context 'has been ticked only once' do
        before { subject.tick! }
        it { is_expected.to be_running }
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it { is_expected.to be_success }
      end
    end
  end

  describe '.halt!' do
    context 'required ticks is 2 and has been ticked once' do
      let(:necessary_ticks) { 2 }
      before { subject.tick! }
      before { subject.halt! }

      it 'goes back to node default status' do
        is_expected.to be_success
      end
    end
  end
end
