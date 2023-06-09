# frozen_string_literal: true

class SomeClass
  def display_name
    'some-custom-class-name'
  end
end

describe BehaviorTree::TreeStructure::Printer do
  subject do
    random_status = ->(_context, node) {
      r = rand
      if r < 0.5
        node.status.failure!
      elsif r < 0.8
        node.status.running!
      else
        node.status.success!
      end
    }

    BehaviorTree::Builder.build do
      seq do
        sel do
          task random_status
          task random_status
        end
        seq do
          task random_status
        end
      end
    end
  end

  before { 100.times { subject.tick! } }

  describe '.snake_case' do
    it { expect(subject.send(:snake_case, 'aaa')).to eq 'aaa' }
    it { expect(subject.send(:snake_case, 'SomeClass')).to eq 'some_class' }
    it { expect(subject.send(:snake_case, 'helloWorld')).to eq 'hello_world' }
    it { expect(subject.send(:snake_case, '_hElloWor_LD_')).to eq '_h_ello_wor_ld_' }
    it { expect(subject.send(:snake_case, '_hEll-oWor_LD_')).to eq '_h_ell_o_wor_ld_' }
  end

  describe '.bool_yes_no' do
    it { expect(subject.send(:bool_yes_no, true)).to eq 'yes' }
    it { expect(subject.send(:bool_yes_no, false)).to eq 'no' }
  end

  describe '.resolve_display_name' do
    context 'has module' do
      let(:spell_checker) { DidYouMean::SpellChecker.new dictionary: [] }

      it { expect(subject.send(:resolve_display_name, spell_checker)).to eq 'spell_checker' }
    end

    context 'has no module' do
      it { expect(subject.send(:resolve_display_name, [])).to eq 'array' }
    end

    context 'has display name' do
      it { expect(subject.send(:resolve_display_name, SomeClass.new)).to eq 'some-custom-class-name' }
    end
  end

  describe '.tree_lines' do
    let(:lines) { subject.send :tree_lines }

    it { expect(lines).to be_an Array }
    it { expect(lines.count).to eq 6 }

    it do
      # /A matches string beginning.
      expect(lines[0]).to match(/\A└─[a-z]/)
      expect(lines[1]).to match(/\A\s+├─[a-z]/)
      expect(lines[2]).to match(/\A\s+│     ├─[a-z]/)
      expect(lines[3]).to match(/\A\s+│     └─[a-z]/)
      expect(lines[4]).to match(/\A\s+└─[a-z]/)
      expect(lines[5]).to match(/\A\s+└─[a-z]/)
    end
  end

  describe '.print' do
    it { expect { subject.print }.to output(/∅/).to_stdout }
    it { expect { subject.print }.to output(/Cycles: no./).to_stdout }
    it { expect { subject.print }.to output(/All nodes are unique object refs: yes./).to_stdout }
    it { expect { subject.print }.to output(/Tree has 6 nodes./).to_stdout }
  end
end
