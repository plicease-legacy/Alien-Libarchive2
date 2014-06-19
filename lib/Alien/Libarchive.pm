package Alien::Libarchive;

use strict;
use warnings;
use File::ShareDir ();
use File::Spec;
use Alien::Libarchive::ConfigData;
use constant _share_dir => File::ShareDir::dist_dir('Alien-Libarchive');
use constant _alien_libarchive019 => 1;

# ABSTRACT: Build and make available libarchive
# VERSION

my $cf = 'Alien::Libarchive::ConfigData';

sub _catfile {
  my $path = File::Spec->catfile(@_);
  $path =~ s{\\}{/}g if $^O eq 'MSWin32';
  $path;
}

sub _catdir {
  my $path = File::Spec->catdir(@_);
  $path =~ s{\\}{/}g if $^O eq 'MSWin32';
  $path;
}

=head1 SYNOPSIS

Build.PL

 use Alien::Libarchive;
 use Module::Build;
 
 my $alien = Alien::Libarchive->new;
 my $build = Module::Build->new(
   ...
   extra_compiler_flags => $alien->cflags,
   extra_linker_flags   => $alien->libs,
   ...
 );
 
 $build->create_build_script;

Makefile.PL

 use Alien::Libarchive;
 use ExtUtils::MakeMaker;
 
 my $alien = Alien::Libarchive;
 WriteMakefile(
   ...
   CFLAGS => $alien->cflags,
   LIBS   => $alien->libs,
 );

FFI::Raw

 use Alien::Libarchive;
 use FFI::Raw;
 
 my($dll) = Alien::Libarchive->new->dlls;
 FFI::Raw->new($dll, 'archive_read_new', FFI::Raw::ptr);

FFI::Sweet

 use Alien::Libarchive;
 use FFI::Sweet;
 
 ffi_lib( Alien::Libarchive->new->dlls );
 attach_function 'archive_read_new', [], _ptr;

=head1 DESCRIPTION

This distribution installs libarchive so that it can be used by other Perl
distributions.  If already installed for your operating system, and it can
be found, this distribution will use the libarchive that comes with your
operating system, otherwise it will download it from the internet, build
and install it.

If you set the environment variable ALIEN_LIBARCHIVE to 'share', this
distribution will ignore any system libarchive found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of libarchive and an upgrade path for the 
system libarchive is not possible.

=head2 Requirements

=head3 operating system install

The development headers and libraries for libarchive

=over 4

=item Debian

On Debian you can install these with this command:

 % sudo apt-get install libarchive-dev

=item Cygwin

On Cygwin, make sure that this package is installed

 libarchive-devel

=item FreeBSD

libarchive comes with FreeBSD as of version 5.3.

=back

=head3 from source install

A C compiler and any prerequisites for building libarchive.

=over 4

=item Debian

On Debian build-essential should be good enough:

 % sudo apt-get install build-essential

=item Cygwin

On Cygwin, I couldn't get libarchive to build without making a
minor tweak to one of the include files.  On Cygwin this module
will patch libarchive before it attempts to build if it is
version 3.1.2.

=back

=cut

sub new
{
  my($class) = @_;
  bless {}, $class;
}

=head1 METHODS

=head2 cflags

Returns the C compiler flags necessary to build against libarchive.

Returns flags as a list in list context and combined into a string in
scalar context.

=cut

sub cflags
{
  my($class) = @_;
  my @cflags = @{ $cf->config("cflags") };
  unshift @cflags, '-I' . _catdir(_share_dir, 'libarchive019', 'include' )
    if $class->install_type eq 'share';
  wantarray ? @cflags : "@cflags";
}

=head2 libs

Returns the library flags necessary to build against libarchive.

Returns flags as a list in list context and combined into a string in
scalar context.

=cut

sub libs
{
  my($class) = @_;
  my @libs = @{ $cf->config("libs") };
  if($class->install_type eq 'share')
  {
    if($cf->config('msvc'))
    {
      unshift @libs, '/libpath:' . _catdir(_share_dir, 'libarchive019', 'lib');
      @libs = map { s{^.*(\\|/)}{} if m/archive_static\.lib$/; $_ } @libs;
    }
    else
    {
      unshift @libs, '-L' . _catdir(_share_dir, 'libarchive019', 'lib');
    }
  }
  wantarray ? @libs : "@libs";
}

=head2 dlls

Returns a list of dynamic libraries (usually a list of just one library)
that make up libarchive.  This can be used for L<FFI::Raw>.

Returns just the first dynamic library found in scalar context.

=cut

sub dlls
{
  my($class) = @_;
  my @list;
  if($class->install_type eq 'system')
  {
    require Alien::Libarchive::Installer;
    @list = Alien::Libarchive::Installer->system_install( alien => 0 test => 'ffi' )->dlls;
  }
  else
  {
    @list = map { _catfile(_share_dir, 'libarchive019', 'dll', $_) }
            @{ $cf->config("dlls") };
  }
  wantarray ? @list : $list[0];
}

=head2 install_type

Returns the install type, one of either C<system> or C<share>.

=cut

sub install_type
{
  $cf->config("install_type");
}

=head2 pkg_config_dir

Returns a path that contains the libarchive.pc file which can be used
by pkg-config for linking against libarchive.

=cut

sub pkg_config_dir
{
  _catdir(_share_dir, 'libarchive019', 'lib', 'pkgconfig');
}

=head2 pkg_config_name

Returns the name by which pkg-config knows libarchive (should always
be libarchive).

=cut

sub pkg_config_name
{
  'libarchive';
}

# extract the macros from the header files, this is a private function
# because it may not be portable.  Used by the Archive::Libarchive::XS
# build process (and maybe Archive::Libarchive::FFI) to automatically
# generate constants
# UPDATE: this maybe should use C::Scan or C::Scan::Constants
sub _macro_list
{
  require Config;
  require File::Temp;
  require File::Spec;

  my $alien = Alien::Libarchive->new;
  my $cc = "$Config::Config{ccname} $Config::Config{ccflags} " . $alien->cflags;

  my $fn = File::Spec->catfile(File::Temp::tempdir( CLEANUP => 1 ), "test.c");

  do {
    open my $fh, '>', $fn;
    print $fh "#include <archive.h>\n";
    print $fh "#include <archive_entry.h>\n";
    close $fh;
  };

  my @list;
  my $cmd = "$cc -E -dM $fn";
  foreach my $line (`$cmd`)
  {
    if($line =~ /^#define ((AE|ARCHIVE)_\S+)/)
    {
      push @list, $1;
    }
  }
  sort @list;
}

=head1 CAVEATS

Debian Linux and FreeBSD (9.0) have been tested the most
in development of this distribution.

Patches to improve portability and platform support would be eagerly
appreciated.

If you reinstall this distribution, you may need to reinstall any
distributions that depend on it as well.

=head1 SEE ALSO

=over 4

=item L<Alien::Libarchive::Installer>

=item L<Archive::Libarchive::XS>

=item L<Archive::Libarchive::FFI>

=item L<Archive::Libarchive::Any>

=item L<Archive::Ar::Libarchive>

=item L<Archive::Peek::Libarchive>

=item L<Archive::Extract::Libarchive>

=back

=cut

1;
