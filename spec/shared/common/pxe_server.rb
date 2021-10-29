shared_examples 'common::pxe_install' do
  context 'rule cramfs' do
    describe file('/etc/xinetd.d/tftp') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{port.*=.*69} }
    end
  end
end
