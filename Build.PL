use Module::Build;

my $build = Module::Build->new(
    module_name    => 'Operator::Util',
    license        => 'Perl_5',
    create_license => 1,
    create_readme  => 1,
    configure_requires => {
        'Module::Build' => 0.36_14,
    },
    build_requires => {
        'ok'         => 0,
        'Test::More' => 0.40,
    },
    requires => {
        'perl'   => '5.6.0',
        'parent' => 0,
    },
    meta_merge => {
        resources => {
            repository => {
                type => 'git',
                url  => 'git://github.com/patch/operator-util-pm5.git',
                web  => 'http://github.com/patch/operator-util-pm5',
            },
            bugtracker => 'http://github.com/patch/operator-util-pm5/issues',
        },
    },
);

$build->create_build_script;
