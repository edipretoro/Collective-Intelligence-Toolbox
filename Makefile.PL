use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Collective::Intelligence::Toolbox',
    AUTHOR              => 'Emmanuel Di Pretoro <edipretoro@gmail.com>',
    VERSION_FROM        => 'lib/Collective/Intelligence/Toolbox.pm',
    ABSTRACT_FROM       => 'lib/Collective/Intelligence/Toolbox.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Collective-Intelligence-Toolbox-*' },
);
