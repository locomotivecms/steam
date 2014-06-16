require 'spec_helper'

describe Locomotive::Steam::Utils::LocalizedTree do

  describe '#to_hash' do
    let(:tree) { [ 'a.fr.haml', 'a.haml', 'b.xml', 'b.fr.haml', 'z.txt' ] }
    let(:extensions) { ['haml','xml'] }
    subject { Locomotive::Steam::Utils::LocalizedTree.new(tree, extensions).to_hash }


    it { should be_kind_of Hash }

    it 'has root as key' do
      subject.keys.should eq ['a', 'b']
    end

    it { should eql ({
        'a' => {fr: 'a.fr.haml', default: 'a.haml'},
        'b' => {default:  'b.xml', fr: 'b.fr.haml'}
      })
    }

    context 'multiple extensions' do
      let(:tree) { [ 'a.fr.haml.xml', 'a.haml', 'b.xml.haml', 'b.fr.haml'] }
      it { should eql ({
          'a' => {fr: 'a.fr.haml.xml', default: 'a.haml'},
          'b' => {default:  'b.xml.haml', fr: 'b.fr.haml'}
        })
      }

    end
  end
end
