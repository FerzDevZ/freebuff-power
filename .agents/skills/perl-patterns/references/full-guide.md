my $obj = new Foo(bar => 1);            # Bad
my $obj = Foo->new(bar => 1);           # Good

# 3. Excessive reliance on $_
map { process($_) } grep { validate($_) } @items;  # Hard to follow
my @valid = grep { validate($_) } @items;           # Better: break it up
my @results = map { process($_) } @valid;

# 4. Disabling strict refs
no strict 'refs';                        # Almost always wrong
${"My::Package::$var"} = $value;         # Use a hash instead

# 5. Global variables as configuration
our $TIMEOUT = 30;                       # Bad: mutable global
use constant TIMEOUT => 30;              # Better: constant
# Best: Moo attribute with default

# 6. String eval for module loading
eval "require $module";                  # Bad: code injection risk
eval "use $module";                      # Bad
use Module::Runtime 'require_module';    # Good: safe module loading
require_module($module);
```

**Remember**: Modern Perl is clean, readable, and safe. Let `use v5.36` handle the boilerplate, use Moo for objects, and prefer CPAN's battle-tested modules over hand-rolled solutions.
