% ============================================================
% ЛАБОРАТОРНАЯ РАБОТА №1: Генеалогические отношения
% Файл: family.pl (Уровень 2)
% ============================================================

:- set_prolog_flag(encoding, utf8).
:- discontiguous man/1, woman/1, parent/2, birth_year/2, profession/2, location/2.

% ============================================================
% 1. ФАКТЫ: Пол
% ============================================================
man(ivan).    man(petr).    man(sergey).    man(alexei).
man(dmitry).  man(boris).   man(igor).      man(oleg).

woman(maria). woman(elena). woman(anna).    woman(tatiana).
woman(olga).  woman(ira).   woman(natalia). woman(ksenia).

% ============================================================
% 2. ФАКТЫ: Родительские связи (ЕДИНОЕ ДЕРЕВО!)
% ============================================================
% ПОКОЛЕНИЕ 1 (корни): ivan + maria
parent(ivan, petr).    parent(ivan, elena).   parent(ivan, sergey).
parent(maria, petr).   parent(maria, elena).  parent(maria, sergey).

% ПОКОЛЕНИЕ 2: дети ivan/maria
% Ветвь 1: petr + anna
parent(petr, alexei).  parent(petr, tatiana).
parent(anna, alexei).  parent(anna, tatiana).
man(petr). woman(anna).

% Ветвь 2: elena + dmitry  
parent(elena, igor).   parent(elena, oleg).
parent(dmitry, igor).  parent(dmitry, oleg).
woman(elena). man(dmitry).

% Ветвь 3: sergey + olga
parent(sergey, boris). parent(sergey, ksenia).
parent(olga, boris).   parent(olga, ksenia).
man(sergey). woman(olga).

% ПОКОЛЕНИЕ 3: внуки ivan/maria
parent(alexei, ivan_jr).
parent(tatiana, maria_jr).
parent(igor, petr_jr).
parent(boris, elena_jr).

% ============================================================
% 3. Расширенные атрибуты (Уровень 2)
% ============================================================
birth_year(ivan, 1940).   birth_year(maria, 1942).
birth_year(petr, 1965).   birth_year(elena, 1967).   birth_year(sergey, 1963).
birth_year(anna, 1966).   birth_year(dmitry, 1968).  birth_year(olga, 1964).
birth_year(alexei, 1990). birth_year(tatiana, 1992).
birth_year(igor, 1991).   birth_year(oleg, 1993).
birth_year(boris, 1989).  birth_year(ksenia, 1994).
birth_year(ivan_jr, 2018). birth_year(maria_jr, 2020).
birth_year(petr_jr, 2019). birth_year(elena_jr, 2017).

profession(ivan, engineer).    profession(maria, teacher).
profession(petr, programmer).  profession(elena, designer).
profession(sergey, doctor).    profession(dmitry, manager).
profession(alexei, student).   profession(boris, analyst).

location(ivan, moscow).    location(maria, moscow).
location(petr, moscow).    location(elena, spb).
location(sergey, kazan).   location(alexei, moscow).
location(boris, moscow).

% ============================================================
% 4. БАЗОВЫЕ ПРОИЗВОДНЫЕ ПРЕДИКАТЫ
% ============================================================
father(X, Y) :- parent(X, Y), man(X).
mother(X, Y) :- parent(X, Y), woman(X).
son(X, Y) :- parent(Y, X), man(X).
daughter(X, Y) :- parent(Y, X), woman(X).

grandfather(X, Y) :- parent(X, Z), parent(Z, Y), man(X).
grandmother(X, Y) :- parent(X, Z), parent(Z, Y), woman(X).

brother(X, Y) :-
    parent(Z, X), parent(Z, Y),
    man(X), X \= Y.

sister(X, Y) :-
    parent(Z, X), parent(Z, Y),
    woman(X), X \= Y.

uncle(X, Y) :- brother(X, Z), parent(Z, Y).
aunt(X, Y) :- sister(X, Z), parent(Z, Y).

% ============================================================
% 5. РЕКУРСИВНЫЕ ПРЕДИКАТЫ
% ============================================================
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).

descendant(X, Y) :- ancestor(Y, X).

% ============================================================
% 6. СЛОЖНЫЕ ОТНОШЕНИЯ
% ============================================================
cousin_brother(X, Y) :-
    parent(PX, X), parent(PY, Y),
    brother(PX, PY),
    man(X), X \= Y.

cousin_sister(X, Y) :-
    parent(PX, X), parent(PY, Y),
    sister(PX, PY),
    woman(X), X \= Y.

cousin(X, Y) :- cousin_brother(X, Y).
cousin(X, Y) :- cousin_sister(X, Y).

% ============================================================
% 7. ПРЕДИКАТЫ АНАЛИЗА (Уровень 2)
% ============================================================

% --- is_root/1: человек без родителей в БЗ ---
is_root(Person) :-
    (man(Person); woman(Person)),
    \+ parent(_, Person).

% --- generation/2: номер поколения от корня ---
generation(Person, 1) :- is_root(Person).
generation(Child, Gen) :-
    parent(Parent, Child),
    generation(Parent, ParentGen),
    Gen is ParentGen + 1.

% --- common_ancestor/3: ближайший общий предок ---
common_ancestor(X, Y, Ancestor) :-
    ancestor(Ancestor, X),
    ancestor(Ancestor, Y),
    % Проверяем, что нет более "низкого" общего предка
    \+ (
        ancestor(Ancestor, Lower),
        Lower \= Ancestor,
        ancestor(Lower, X),
        ancestor(Lower, Y)
    ).

% --- kinship_distance/3: расстояние через общего предка ---
kinship_distance(X, Y, Distance) :-
    common_ancestor(X, Y, Anc),
    path_up(X, Anc, D1),
    path_up(Y, Anc, D2),
    Distance is D1 + D2.

path_up(X, X, 0).
path_up(Child, Anc, Len) :-
    parent(Parent, Child),
    path_up(Parent, Anc, Sub),
    Len is Sub + 1.

% ============================================================
% 8. ВАЛИДАЦИЯ БАЗЫ ЗНАНИЙ
% ============================================================
no_cycles :-
    \+ ancestor(X, X),
    write('[OK] No cycles detected'), nl.

age_validation :-
    findall(
        (P, C, BP, BC),
        (
            parent(P, C),
            birth_year(P, BP),
            birth_year(C, BC),
            BC - BP < 15
        ),
        Violations
    ),
    (
        Violations = [] 
        -> write('[OK] Age validation passed'), nl
        ;  write('[FAIL] Age issues:'), nl, maplist(print_viol, Violations)
    ).

print_viol((P,C,BP,BC)) :- format('  ~w(~w)->~w(~w) gap=~w~n',[P,BP,C,BC,BC-BP]).

no_self_ancestor :-
    \+ ancestor(X, X),
    write('[OK] No self-ancestor conflicts'), nl.

validate_kb :-
    write('=== Validation ==='), nl,
    no_cycles, age_validation, no_self_ancestor,
    write('=== Done ==='), nl.

% ============================================================
% 9. ВСПОМОГАТЕЛЬНЫЕ ПРЕДИКАТЫ
% ============================================================
person_info(Person) :-
    (man(Person) -> write('Man: '); woman(Person) -> write('Woman: ')),
    write(Person), nl,
    (birth_year(Person, Y) -> format('  Born: ~w~n', [Y]); true),
    (profession(Person, P) -> format('  Job: ~w~n', [P]); true),
    (location(Person, L) -> format('  City: ~w~n', [L]); true),
    findall(C, parent(Person, C), Ch),
    (Ch \= [] -> format('  Children: ~w~n', [Ch]); true).

list_generations :-
    findall(P, (man(P); woman(P)), All),
    sort(All, Sorted),
    maplist(print_gen, Sorted).

print_gen(P) :-
    (generation(P, G) -> format('~w: gen ~w~n', [P, G])
                       ; format('~w: gen ?~n', [P])).