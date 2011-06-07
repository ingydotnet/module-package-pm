BEGIN {
    @INC = grep {
        not(m!/home/ingy/src/!) and
        not(m!/local/share/!) and
        not(m!\bsite!)
    } @INC;
}
use inc::Module::Package 'Ingy:modern 0.09';
