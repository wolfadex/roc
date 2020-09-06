#[macro_use]
extern crate pretty_assertions;
#[macro_use]
extern crate indoc;

extern crate bumpalo;
extern crate roc_can;
extern crate roc_parse;
extern crate roc_region;

mod helpers;

#[cfg(test)]
mod can_inline {
    use crate::helpers::{can_expr_with, test_home};
    use bumpalo::Bump;
    use roc_can::expr::inline_calls;
    use roc_can::expr::Expr::{self, *};
    use roc_can::scope::Scope;
    use roc_types::subs::VarStore;

    fn assert_inlines_to(input: &str, expected: Expr, var_store: &mut VarStore) {
        let arena = Bump::new();
        let scope = &mut Scope::new(test_home());
        let actual_out = can_expr_with(&arena, test_home(), input);
        let actual = inline_calls(var_store, scope, actual_out.loc_expr.value);

        assert_eq!(actual, expected);
    }

    #[test]
    fn inline_empty_record() {
        // fn inline_list_len() {
        let var_store = &mut VarStore::default();

        assert_inlines_to(
            indoc!(
                r#"
                    {}
                "#
            ),
            EmptyRecord,
            var_store,
        );

        // TODO testing with hardcoded variables is very brittle.
        // Should find a better way to test this!
        // (One idea would be to traverse both Exprs and zero out all the Variables,
        // so they always pass equality.)
        // let aliases = SendMap::default();
        // assert_inlines_to(
        //     indoc!(
        //         r#"
        //             Int.isZero 5
        //         "#
        //     ),
        //     LetNonRec(
        //         Box::new(Def {
        //             loc_pattern: Located {
        //                 region: Region::zero(),
        //                 value: Pattern::Identifier(Symbol::ARG_1),
        //             },
        //             pattern_vars: SendMap::default(),
        //             loc_expr: Located {
        //                 region: Region::new(0, 0, 11, 12),
        //                 value: Num(unsafe { Variable::unsafe_test_debug_variable(7) }, 5),
        //             },
        //             expr_var: unsafe { Variable::unsafe_test_debug_variable(8) },
        //             annotation: None,
        //         }),
        //         Box::new(Located {
        //             region: Region::zero(),
        //             value: Expr::Call(
        //                 Box::new((
        //                     unsafe { Variable::unsafe_test_debug_variable(138) },
        //                     Located {
        //                         region: Region::zero(),
        //                         value: Expr::Var(Symbol::BOOL_EQ),
        //                     },
        //                     unsafe { Variable::unsafe_test_debug_variable(139) },
        //                 )),
        //                 vec![
        //                     (
        //                         unsafe { Variable::unsafe_test_debug_variable(140) },
        //                         Located {
        //                             region: Region::zero(),
        //                             value: Var(Symbol::ARG_1),
        //                         },
        //                     ),
        //                     (
        //                         unsafe { Variable::unsafe_test_debug_variable(141) },
        //                         Located {
        //                             region: Region::zero(),
        //                             value: Int(
        //                                 unsafe { Variable::unsafe_test_debug_variable(137) },
        //                                 0,
        //                             ),
        //                         },
        //                     ),
        //                 ],
        //                 CalledVia::Space,
        //             ),
        //         }),
        //         unsafe { Variable::unsafe_test_debug_variable(198) },
        //         aliases,
        //     ),
        //     var_store,
        // )
    }
}