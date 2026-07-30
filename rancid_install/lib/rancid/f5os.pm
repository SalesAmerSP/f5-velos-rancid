package f5os;
##
## rancid 3.14
## Custom F5OS module for F5 VELOS System Controllers and Chassis Partitions
##

use 5.010;
use strict 'vars';
use warnings;
no warnings 'uninitialized';
require(Exporter);
our @ISA = qw(Exporter);

use rancid 3.14;

@ISA = qw(Exporter rancid main);

# load-time initialization
sub import {
    # force a terminal type so as not to confuse the POS
    $ENV{'TERM'} = "vt100";
    0;
}

# post-open(collection file) initialization
sub init {
    # add content lines and separators
    ProcessHistory("","","","!RANCID-CONTENT-TYPE: f5os\n!\n");
    ProcessHistory("COMMENTS","keysort","A1","#\n");
    ProcessHistory("COMMENTS","keysort","B0","#\n");
    ProcessHistory("COMMENTS","keysort","C0","#\n");
    0;
}

# main loop of input of device output
sub inloop {
    my($INPUT, $OUTPUT) = @_;
    my($cmd, $rval);

TOP: while(<$INPUT>) {
        tr/\015//d;
        if (/^Error:/) {
            print STDOUT ("$host clogin error: $_");
            print STDERR ("$host clogin error: $_") if ($debug);
            $clean_run=0;
            last;
        }
        # Match prompt ending in > or # or )#
        while (/[>#]\s*($cmds_regexp)\s*$/) {
            $cmd = $1;
            if (!defined($prompt)) {
                $prompt = ($_ =~ /^([^>#]+[>#])/)[0];
                $prompt =~ s/([][}{)(\\])/\\$1/g;
                print STDERR ("PROMPT MATCH: $prompt\n") if ($debug);
            }
            print STDERR ("HIT COMMAND: $_") if ($debug);
            if (! defined($commands{$cmd})) {
                print STDERR "$host: found unexpected command - \"$cmd\"\n";
                $clean_run = 0;
                last TOP;
            }
            $rval = &{$commands{$cmd}}($INPUT, $OUTPUT, $cmd);
            delete($commands{$cmd});
            if ($rval == -1) {
                $clean_run = 0;
                last TOP;
            }
        }
        if (/[>#]\s*exit$/) {
            $clean_run=1;
            last;
        }
    }
}

# This routine parses "show system version"
sub ShowVersion {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowVersion: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","A1", "#\n# System Version Information:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        ProcessHistory("COMMENTS","keysort","A2", "# $_\n");
    }
    return(0);
}

# This routine parses "show system image"
sub ShowImage {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowImage: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","B1", "#\n# System Image Information:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        ProcessHistory("COMMENTS","keysort","B2", "# $_\n");
    }
    return(0);
}

# This routine parses "show cluster cluster-status"
sub ShowCluster {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowCluster: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","C1", "#\n# Cluster Status Information:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        # Filter out dynamic timestamps from status messages to prevent noisy revision control history
        s/status "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\S+ - /status "/;

        ProcessHistory("COMMENTS","keysort","C2", "# $_\n");
    }
    return(0);
}

# This routine parses "show tenants"
sub ShowTenants {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowTenants: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","D1", "#\n# Tenant Configuration & State:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        ProcessHistory("COMMENTS","keysort","D2", "# $_\n");
    }
    return(0);
}

# This routine parses "show components"
sub ShowComponents {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowComponents: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","E1", "#\n# Hardware Components Information:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        ProcessHistory("COMMENTS","keysort","E2", "# $_\n");
    }
    return(0);
}

# This routine parses "show running-config" (or "write terminal")
sub WriteTerm {
    my($INPUT, $OUTPUT, $cmd) = @_;
    my($lines) = 0;
    print STDERR "    In WriteTerm: $_" if ($debug);

    ProcessHistory("","","", "!\n! Running Configuration:\n!\n");
    while (<$INPUT>) {
        tr/\015//d;
        next if (/^\s*$/);

        if (/^$prompt/) {
            $found_end++;
            last;
        }
        return(-1) if (/command authorization failed/i);

        $lines++;

        # Filter out sensitive information (like passwords, keys, communities)
        if (/(password|encrypted-password|secret|passphrase|community|key-data) (\S+)/ && $filter_pwds >= 1) {
            s/(\Q$1\E) (\S+)/$1 <removed>/;
        }

        # Catch anything that wasn't matched above and save it to the RANCID history
        ProcessHistory("","","","$_");
    }

    if ($lines < 3) {
        printf(STDERR "ERROR: $host configuration appears truncated.\n");
        $found_end = 0;
        return(-1);
    }

    return(0);
}

# This routine parses "show system licensing"
sub ShowLicensing {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowLicensing: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","F1", "#\n# System Licensing Details:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        # Filter out license keys or registration keys if filter_pwds is active to prevent leak
        if (/(registration-key|license-key|key) (\S+)/ && $filter_pwds >= 1) {
            s/(\Q$1\E) (\S+)/$1 <removed>/;
        }

        ProcessHistory("COMMENTS","keysort","F2", "# $_\n");
    }
    return(0);
}

# This routine parses "show system database"
sub ShowDatabase {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowDatabase: $_" if ($debug);

    ProcessHistory("COMMENTS","keysort","G1", "#\n# System Database & Configuration Backups:\n#\n");
    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);
        next if (/^(\s*|\s*$cmd\s*)$/);
        return(-1) if (/command authorization failed/i);

        ProcessHistory("COMMENTS","keysort","G2", "# $_\n");
    }
    return(0);
}

1;

