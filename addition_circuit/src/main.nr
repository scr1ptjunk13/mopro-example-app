fn main(a: Field, b: Field) -> pub Field {
    a + b
}

#[test]
fn test_addition() {
    let result = main(10, 5);
    assert(result == 15);
}

#[test]
fn test_addition_zero() {
    let result = main(0, 7);
    assert(result == 7);
}
