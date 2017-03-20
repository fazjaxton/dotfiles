#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use File::HomeDir;
use Cwd;
use Getopt::Long;

# List of configurations and the links to be created for them
my $configs = {
    "bash" => {
        ".bashrc" => "bash/bashrc",
    },
    "git" => {
        ".gitconfig" => "git/gitconfig",
        ".gitignore_global" => "git/gitignore_global",
    },
    "tmux" => {
        ".tmux.conf" => "tmux/tmux.conf",
    },
    "vim" => {
        ".vimrc" => "vim/vimrc",
        ".vim" => "vim",
    },
};

# Command line options
my $list = 0;
my $all = 0;
my $dryrun = 0;
my $quiet = 0;
my $force = 0;

# Path from home into config directory
my $reldir;
# Configs to install
my @install;
# Names of configs
my @names = sort keys %$configs;
# Script result
my $result = 0;


# Print something if --quiet not specified
sub output {
    if (not $quiet) {
        print @_;
    }
}

sub make_link {
    my $homedir = File::HomeDir->my_home();
    if (! defined $reldir) {
        my $mypath = Cwd::realpath(File::Spec->catfile(getcwd(), $0));
        my $mydir = ((File::Spec->splitpath($mypath))[1]);
        $reldir = File::Spec->abs2rel($mydir, $homedir);
    }
    my $link = File::Spec->catfile($homedir, $_[0]);
    my $target = File::Spec->catfile($reldir, $_[1]);

    # Check if this file already exists and is a link
    my $exists = -e $link;
    my $is_link = -l $link;
    my $create = 1;

    if ($exists) {
        # Don't overwrite existing files (except in certain cases below)
        $create = 0;
        if ($is_link) {
            if (readlink $link eq $target) {
                output "  $link already installed\n";
            } elsif (not $force) {
                output "  $link already exists, use --force to replace\n";
                $result = 1;
            } else {
                if (not $dryrun) {
                    # Delete existing link so creation will succeed
                    if (unlink $link) {
                        $create = 1;
                    } else {
                        output "  Could not remove $link\n";
                        $result = 1;
                    }
                }
            }
        } else {
            # Don't delete regular files or directories
            output "  $link exists and is not a link.  Remove manually.\n";
            $result = 1;
        }
    }

    # Create the link
    if ($create) {
        output "  Creating $link -> $target\n";
        if (not $dryrun) {
            if (! symlink($target, $link)) {
                print "  Error creating link\n";
            }
        }
    }
}

# Parse options
GetOptions(
        "list" => \$list,
        "all" => \$all,
        "dry" => \$dryrun,
        "quiet" => \$quiet,
        "force" => \$force,
) or die;

# If no names given, list available options
if (!$all and scalar @ARGV == 0) {
    $list = 1;
}

if ($list) {
    print "Available configs:\n";
    for my $name (@names) {
        print "  $name\n";
    }
    exit 0;
}

if ($all) {
    # If --all, set to install all configs
    @install = @names;
} else {
    # Otherwise use configs specified on command line
    for my $name (@ARGV) {
        if (! grep(/^$name$/, @names)) {
            print "Unknown config: $name\n";
            exit 1;
        }
        push @install, $name;
    }
}

# Install links for each config
for my $name (@install) {
    my %link_map = %{%$configs{$name}};
    my @links = (keys %link_map);
    output "$name:\n";
    for my $link (@links) {
        my $target = $link_map{$link};
        make_link($link, $target);
    }
}

exit $result;
