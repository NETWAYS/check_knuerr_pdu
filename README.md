check_knuerr_pdu
================

`check_knuerr_pdu.pl` recieves the data from the knuerr\_pdu devices. It can check thresholds of 
the modules.

http://www.netways.de/en/de/produkte/icinga_and_nagios_plugins/knuerr/

### Requirements

* Perl libraries: `Net::SNMP`


### Usage

    check_knuerr_pdu.pl -h

    check_knuerr_pdu.pl --man

    check_knuerr_pdu.pl -H <host> -M <module> [-w <warning>] [-c <critical>]

Options:

    -h      Display this helpmessage.
    -H      The hostname or ipaddress of the knuerr_pdu device.
    -C      The snmp community of the knuerr_pdu device.
    -M      The module to check
    -w      The warning threshold.
    -c      The critical threshold.
    --man   Displays the complete perldoc manpage.

    check_knuerr_cooltherm -h

    check_knuerr_cooltherm --man

    check_knuerr_cooltherm -H <hostname> [<SNMP community>]
