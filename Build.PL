use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Collective::Intelligence::Toolbox',
    license             => 'perl',
    dist_author         => 'Emmanuel Di Pretoro <edipretoro@gmail.com>',
    dist_version_from   => 'lib/Collective/Intelligence/Toolbox.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Collective-Intelligence-Toolbox-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
