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
    },
    "tmux" => {
        ".tmux.conf" => "tmux/tmux.conf",
    },
    "vim" => {
        ".vimrc" => "vim/vimrc",
        ".vim" => "vim",
    },
    "gnome-css" => {
        ".config/gtk-3.0/gtk.css" => "gtk3/gtk.css",
    },
    "nvim" => {
        ".config/nvim" => "nvim",
    },
    "xmodmap" => {
        ".Xmodmap" => "xmodmap/xmodmap",
    },
};

# A link made into this config directory
my $config_dir_link = ".dotfiles";

# Command line options
my $list = 0;
my $all = 0;
my $dryrun = 0;
my $quiet = 0;
my $force = 0;

# User's home directory
my $homedir;
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

sub init {
    my $mypath = Cwd::realpath(File::Spec->catfile(getcwd(), $0));
    my $mydir = ((File::Spec->splitpath($mypath))[1]);
    $homedir = File::HomeDir->my_home();
    $reldir = File::Spec->abs2rel($mydir, $homedir);
}

sub make_link {
    my $link = File::Spec->catfile($homedir, $_[0]);

    # Path out of link directory
    my $is_dir = -d $_[0];
    my $link_path = (File::Spec->splitpath($_[0], $is_dir))[1];
    my $abs_link_path = File::Spec->catfile($homedir, $link_path);
    my $path_out = File::Spec->abs2rel($homedir, $abs_link_path);

    my $target_prefix = File::Spec->catfile($path_out, $reldir);
    my $target = File::Spec->catfile($target_prefix, $_[1]);

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


init();

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

# If this repo isn't checked out at ~/.dotfiles, make a link ~/.dotfiles into
# this directory so config files can use this path if they need it.
if ($reldir ne $config_dir_link) {
    if (! -l File::Spec->catfile($homedir, $config_dir_link)) {
        make_link($config_dir_link, "");
    }
}

# Install links for each config
for my $name (@install) {
    my %link_map = %{$$configs{$name}};
    my @links = (keys %link_map);
    output "$name:\n";
    for my $link (@links) {
        my $target = $link_map{$link};
        make_link($link, $target);
    }
}

exit $result;
