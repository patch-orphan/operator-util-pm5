use Module::Build;

my $build = Module::Build->new(
    module_name  => 'Operator::Util',
    license      => 'perl',
    build_requires => {
        'ok'         => '0.01',
        'Test::More' => '0.40',
    },
    requires => {
        'perl' => '5.6.0',
    },
    meta_add => {
        resources => {
            homepage   => 'http://github.com/patch/operator-util-pm5',
            repository => 'git://github.com/patch/operator-util-pm5.git',
        },
    },
);

$build->create_build_script;
