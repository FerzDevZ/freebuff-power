# 2. String-form system (shell injection)
system("convert $user_file output.png"); # CRITICAL vulnerability

# 3. SQL string interpolation
$dbh->do("DELETE FROM users WHERE id = $id");  # SQLi

# 4. eval with user input (code injection)
eval $user_code;                         # Remote code execution

# 5. Trusting $ENV without sanitizing
my $path = $ENV{UPLOAD_DIR};             # Could be manipulated
system("ls $path");                      # Double vulnerability

# 6. Disabling taint without validation
($input) = $input =~ /(.*)/s;           # Lazy untaint — defeats purpose

# 7. Raw user data in HTML
print "<div>Welcome, $username!</div>";  # XSS

# 8. Unvalidated redirects
print $cgi->redirect($user_url);         # Open redirect
```

**Remember**: Perl's flexibility is powerful but requires discipline. Use taint mode for web-facing code, validate all input with allowlists, use DBI placeholders for every query, and encode all output for its context. Defense in depth — never rely on a single layer.
