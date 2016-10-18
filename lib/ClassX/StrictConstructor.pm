class X::UnknownAttribute is Exception {
    has @.extras;
    has $.typename;

    method message {
        "The following attributes are not declared for type $!typename: {@!extras.join(", ")}"
    }
}

role ClassX::StrictConstructor {
    sub has_attr($type, $attr) {
        my $ret = True;
        $type.^get_attribute_for_usage('$!' ~ $attr);
        CATCH {
            default { $ret = False }
        }
        return $ret;
    }

    method new(*%attrs) {
        my @extras;
        for %attrs.keys -> $attr {
            unless has_attr(self.WHAT, $attr) {
                my $inherited = has_attr(any(self.^parents), $attr);
                @extras.push: $attr unless $inherited;
            }
        }
        if @extras {
            die X::UnknownAttribute.new(typename => self.^name, :@extras) 
        }
        nextsame;
    }
}
