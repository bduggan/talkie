
use Test;
use Markie;

my $m;
is md-to-html('some `inline code` here'),
    'some <pre class="inline">inline code</pre>here',
    'inline code';
is md-to-html(q:to/ONE/),q:to/TWO/, 'multiline code block';
     multiline
     ```
     code block
     ```
     and some more stuff
     ONE
     multiline
     <pre>code block
     </pre>and some more stuff
     TWO

is md-to-html('http://google.com'), '<a href="http://google.com">http://google.com</a>', 'rendered url';

is md-to-html('link to http://google.com'), q:to/DONE/.trim, 'parsed url';
    link to <a href="http://google.com">http://google.com</a>
    DONE

is md-to-html('1 < 2'), '1 &lt; 2', 'escape';

done-testing;

