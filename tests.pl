% ============================================================
% ТЕСТЫ ДЛЯ ЛР №1 (Уровень 2 — КОРРЕКТНЫЕ ПАРЫ)
% ============================================================

:- ensure_loaded('family.pl').

% --- Базовые тесты (Уровень 1) ---
test1 :- write('1. Children of ivan: '), findall(X, parent(ivan, X), L), write(L), nl.
test2 :- write('2. Father of alexei: '), father(X, alexei), write(X), nl.
test3 :- write('3. Ancestors of boris: '), findall(X, ancestor(X, boris), L), write(L), nl.
test4 :- write('4. Cousin of alexei: '), (cousin(alexei, X) -> write(X), nl ; write('none'), nl).
test5 :- write('5. All women: '), findall(X, woman(X), L), write(L), nl.

% --- Анализ (Уровень 2) ---
test6 :-
    write('6. Generation of boris: '),
    generation(boris, G), format('~w (root=1, children=2, grandchildren=3)~n', [G]).

test7 :-
    write('7. Common ancestor of alexei AND igor (cousins): '),
    % alexei и igor — двоюродные братья, общий предок: ivan/maria
    findall(A, common_ancestor(alexei, igor, A), List),
    (List = [] -> write('none') ; head(List, Anc), write(Anc)), nl.

test8 :-
    write('8. Kinship distance(alexei, igor): '),
    kinship_distance(alexei, igor, D), format('~w (expected: 4)~n', [D]).

test9 :-
    write('9. Person info for boris:~n'),
    person_info(boris).

test10 :-
    write('10. Generations list (first 10):~n'),
    list_generations.

% --- Валидация ---
test11 :-
    write('11. KB validation:~n'),
    validate_kb.

% --- Дополнительные ---
test12 :-
    write('12. Born after 1990: '),
    findall(P, (birth_year(P,Y), Y>1990), L), write(L), nl.

test13 :-
    write('13. Programmers: '),
    findall(P, profession(P, programmer), L), write(L), nl.

test14 :-
    write('14. In moscow: '),
    findall(P, location(P, moscow), L), write(L), nl.

test15 :-
    write('15. All parent->child (first 10):~n'),
    parent(P,C), format('  ~w -> ~w~n', [P,C]), fail; nl.

% --- Вспомогательный предикат ---
head([H|_], H).

% --- Запуск всех тестов ---
run_all_tests :-
    write('=== STARTING TESTS (Level 2, CORRECTED) ==='), nl, nl,
    test1, test2, test3, test4, test5,
    test6, test7, test8, test9, test10,
    test11, test12, test13, test14, test15,
    nl, write('=== ALL TESTS COMPLETED ==='), nl.