# Total Coloring

Program na hledání Totálního obarvení grafu (https://en.wikipedia.org/wiki/Total_coloring) psaný v Prologu.

Graf reprezentuji seznamem vrcholů a seznamem hran. Formát je tedy následující: _graph(Vrcholy,Hrany)_, kde hrana je navíc formátu _e(V1,V2)_. Důležité je, že vrcholy grafu nesmí být čísla (pak by program nerozeznal barvu od názvu vrcholu), v testovacích vstupech proto volím písmena. Příklad grafu: `graph([a,b,c],[e(a,b),e(b,c),e(c,a)]`

Algoritmus nalezení totálního obarvení grafu funguje na základě programování s omezujícími podmínkami (CSP) s metodou Look Ahead. Proměnné (variables) problému v CSP jsou jednotlivé hrany a vrcholy, kterým musí být přidělena barva. Barva je přirozené číslo, doménou jsou tedy přirozená čísla od 1 do ChN, kde ChN je totální chromatické číslo grafu (to na začátku také neznáme). Jako omezující podmínky (constraints) definuji listy, kde každý list (podmínka) v listu podmínek musí splňovat globální podmínku All Different, tedy žádné dva prvky v jednom listu nesmí být stejné.

Jeko první naleznu maximální stupeň vrcholu v grafu, a to proto, protože platí nerovnost **χ″(G) ≥ Δ(G) + 1**. Na základě této nerovnosti vygeneruji doménu proměnných, ze které zkusím přiřadit za jednu z proměnných příslušnou barvu. Příslušnou proměnnou nahradím ve všech podmínkách za přidělenou barvu a zkontroluji, zda nikde nebyla porušena podmínka All Different. Pokud ne, mohu přiřazovat barvu další proměnné. Metoda Look Ahead přichází na řadu, když už mám nějakou barvu přiřazenou. Poté totiž před přiřazením barvy vybrané proměnné zkontroluji, zda se vyskytuje v nějaké podmínce s proměnnou, která už barvu přiřazenou má, tedy tuto barvu mít nemůže. Všechny barvy, které by byly v konfliktu, poté z domény pro tento vrchol/hranu odstraním, tedy vyberu určitě nekonfliktní přiřazení (nebo žádné neexistuje a nastává backtrack). Pokud pro příslušnou doménu nekonfliktní obarvení neexistuje, rozšířím doménu o jednu barvu a zkouším barvit znovu, tentokrát více barvami. 

Pro graf jsem si podle definice úplného obarvení rafu zadefinoval dva druhy podmínek (constraints):

1. Pro každý vrchol musí být všechny hrany, které z něj vychází, různě obarvené.
2. Pro každou hranu musí být různě obarvená tato hrana a její příslušné krajní vrcholy.

Program lze testovat přímo na pravidlech, která jsou v něm uvedená. Obsahují následující grafy:

- úplný graf na 3 vrcholech,
- cyklus délky 5,
- Petersenův graf,
- hvězdicový graf na 5 vrcholech,
- pentagram,
- hvězdicový graf na 10 vrcholech,
- Chvátalův graf,
- úplný graf na 7 vrcholech,
- cyklus délky 14,
- úplný bipartitní graf na 4+4 vrcholech,
- hyperkrychle dimenze 3.

Pro každý graf najde program řešení velmi rychle, nejdéle mu trvá úplný bipartitní graf na 4+4 vrcholech.

Výstup testů je jak totální chormatické číslo, tak příslušné obarvení, kde u vrcholu/hrany je za pomlčkou uvedené číslo barvy, kterou je možné příslušný vrchol/hranu obarvit, aby se jednalo o úplné obarvení. Příklad výstupu pro příklad grafu uvedený výše: `3 [a-3,b-2,c-1,e(a,b)-1,e(b,c)-3,e(c,a)-2]`.
