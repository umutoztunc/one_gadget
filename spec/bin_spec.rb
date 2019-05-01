describe 'Binary' do
  before(:all) do
    @bin = File.join(__dir__, '..', 'bin', 'one_gadget')
    @lib = File.join(__dir__, '..', 'lib')
  end

  it 'help' do
    expect(`env ruby -I#{@lib} #{@bin}`).to eq <<-EOS
Usage: one_gadget [file] [options]
    -b, --build-id BuildID           BuildID[sha1] of libc.
    -f, --[no-]force-file            Force search gadgets in file instead of build id first.
    -n, --near FUNCTIONS/FILE        Order gadgets by their distance to the given functions or to the GOT functions of the given file.
    -l, --level OUTPUT_LEVEL         The output level.
                                     OneGadget automatically selects gadgets with higher successful probability.
                                     Increase this level to ask OneGadget show more gadgets it found.
                                     Default: 0
    -r, --[no-]raw                   Output gadgets offset only, split with one space.
    -s, --script exploit-script      Run exploit script with all possible gadgets.
                                     The script will be run as 'exploit-script $offset'.
        --info BuildID               Show version information given BuildID.
        --version                    Current gem version.
    EOS
  end

  it 'near functions' do
    skip 'Windows' unless RUBY_PLATFORM =~ /linux/
    file = data_path('libc-2.24-8cba3297f538691eb1875be62986993c004f3f4d.so')
    expect(`env ruby -I#{@lib} #{@bin} -n wscanf,pwrite -l 1 -r #{file}`).to eq <<-EOS
Gadgets near pwrite(0xd9b70):
878577 878565 756280 258986 258902

Gadgets near wscanf(0x6afe0):
258986 258902 756280 878565 878577

    EOS
  end

  it 'near file' do
    skip 'Windows' unless RUBY_PLATFORM =~ /linux/
    bin_file = data_path('testNearFile.elf')
    lib_file = data_path('libc-2.24-8cba3297f538691eb1875be62986993c004f3f4d.so')
    expect(`env ruby -I#{@lib} #{@bin} -n #{bin_file} -l 1 -r #{lib_file}`).to eq <<-EOS
Gadgets near exit(0x359d0):
258902 258986 756280 878565 878577

Gadgets near puts(0x68fe0):
258986 258902 756280 878565 878577

Gadgets near printf(0x4f1e0):
258986 258902 756280 878565 878577

Gadgets near strlen(0x80420):
756280 258986 258902 878565 878577

Gadgets near __cxa_finalize(0x35c70):
258902 258986 756280 878565 878577

Gadgets near __libc_start_main(0x201a0):
258902 258986 756280 878565 878577

    EOS
  end
end
