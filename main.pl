% Zapoctovy program - NEPROCEDURALNI PROGRAMOVANI - graph total coloring

% vertexDegree(+H,+V,-C) :- v promenne C ulozi pocet vyskytu vrcholu V v seznamu hran H
vertexDegree([],_,0). % baze
vertexDegree([e(V,_)|Ys],V,Count) :-
    vertexDegree(Ys,V,CountPrev), Count is CountPrev + 1,!. % V je to, co hledam -> zapocitat
vertexDegree([e(_,V)|Ys],V,Count) :-
    vertexDegree(Ys,V,CountPrev), Count is CountPrev + 1,!. % V je to, co hledam -> zapocitat
vertexDegree([e(V,W)|Ys],DifferentVertex,C) :-
    dif(V,DifferentVertex), dif(W,DifferentVertex), vertexDegree(Ys,DifferentVertex,C),!. % Hlava seznamu je neco jineho, nez hledam -> preskocit

% maxDegree(+V,+H,-MD) :- v promenne MD ulozi stupen vrcholu, ktery je v grafu maximalni
maxDegree(Vertices,Edges,MaxDeg) :- maxDegree(Vertices,Edges,0,MaxDeg),!.

maxDegree([],_,AcDeg,AcDeg).
maxDegree([V|Vs],Edges,AcDeg,MaxDeg) :- vertexDegree(Edges,V,Nd), Nd >= AcDeg, maxDegree(Vs,Edges,Nd,MaxDeg). % mam vyssi nebo stejny stupen
maxDegree([V|Vs],Edges,AcDeg,MaxDeg) :- vertexDegree(Edges,V,Nd), Nd < AcDeg, maxDegree(Vs,Edges,AcDeg,MaxDeg). % mam mensi stupen

% allDifferent(+List) :- vraci true, pokud jsou vsechny prvky v listu List unikatni
allDifferent(List) :- sort(List,SortedList), length(List,OrigLen), length(SortedList,SortLen), OrigLen == SortLen.

% allDifferentLists(+ListOfLists) :- aplikuje allDifferent na vsechny seznamy v seznamu seznamu a pokud kazdy z nich splnuje allDifferent, vrati true.
allDifferentLists([]).
allDifferentLists([FirstList|OtherLists]) :- allDifferent(FirstList), allDifferentLists(OtherLists).

% listNto1(+N,-List) :- vytvori list cisel od N do 1
listNto1(N,_) :- N < 1, fail.
listNto1(0,[]).
listNto1(N,[N|List]) :- N > 0, NextN is N - 1, listNto1(NextN,List),!.

% vertexEdgesConstraint(+graph(V,E),-Constraints) :- pro zadany graf vrati seznam seznamu, kde pro kazdy vrchol Vx je seznam obsahujici vsechny hrany, ktere z (nebo do) Vx vedou
vertexEdgesConstraint(graph([],_), []).
vertexEdgesConstraint(graph([X|Xs],Edges), [Y|Output]) :- edgesForVertex(X,Edges,Out), Y = Out, vertexEdgesConstraint(graph(Xs,Edges),Output).

% edgesForVertex(+Vertex,+Edges,-Output) :- vrati vsechny hrany, kde se zadany vrchol vyskytuje
edgesForVertex(_,[],[]).
edgesForVertex(V,[e(V1,V2)|Es],Out) :- V1 \= V, V2 \= V, edgesForVertex(V,Es,Out),!. % ani jeden vrchol hrany neni hledany
edgesForVertex(V,[e(V1,V2)|Es],[e(V1,V2)|Out]) :- (V1 == V; V2 == V), edgesForVertex(V,Es,Out),!. %jeden z nich je muj vrchol

% edgeVerticesConstraint(+graph(V,E),-Constraints) :- pro kazdou hranu vrati seznam kde je ona a jeji dva koncove vrcholy
edgeVerticesConstraint(graph(_,[]), []).
edgeVerticesConstraint(graph(_,[e(V1,V2)|Es]), [Y|Out]) :- Y = [e(V1,V2),V1,V2], edgeVerticesConstraint(graph(_,Es),Out),!.

% allEdgesAndVertices(+graph(V,E),-Output) :- pro graf vyda seznam ktery obsahuje konkatenaci seznamu vrcholu a seznamu hran
allEdgesAndVertices(graph(Vertices,Edges),Out) :- append(Vertices,Edges,Out).

% replace(+Orig,+New,+List,-NewList) :- nahradi v listu List prvek Orig za prvek New a vyda vysledek v NewListu
replace(_,_,[],[]).
replace(Ori,New,[Ori|T],[New|T2]) :- replace(Ori,New,T,T2).
replace(Ori,New,[H|T],[H|T2]) :- dif(H,Ori), replace(Ori,New,T,T2).

% replaceEverywhere(+Orig,+New,+List,-NewList) :- replace pro seznam seznamu -> tj. provede replace v kazdem listu v zadanem listu
replaceEverywhere(_,_,[],[]).
replaceEverywhere(Or,New,[FirstList|ListOfLists],[NewFirst|Sol]) :- replace(Or,New,FirstList,NewFirst), replaceEverywhere(Or,New,ListOfLists,Sol),!.

% removeList(+List1,+List2,-Output) :- v seznamu Output vrati List1 - List2, tj. prvky v List2 jsou z List1 smazany
removeList([],_,[]).
removeList([X|Tail],L2,Result) :- member(X,L2), !, removeList(Tail,L2,Result). % prvek X je v L2 -> smazat
removeList([X|Tail],L2,[X|Result]) :- removeList(Tail,L2,Result).

% onlyNumbers(+List,-Out) :- v seznamu Out vrati poue ty prvky ze seznamu List, ktere jsou cisla
onlyNumbers([],[]).
onlyNumbers([X|Xs],[X|Numbers]) :- number(X), onlyNumbers(Xs,Numbers),!.
onlyNumbers([X|Xs],Numbers) :- \+ number(X), onlyNumbers(Xs,Numbers),!.

% notToUseColors(+Vertex,+Constraints,-Out) :- v seznamu Out vrati ty barvy (cisla), ktera se nekde v Constraintu vyskytuji se zadanym vrcholem (tj. dany vrchol tuto hodnotu mit nesmi)
notToUseColors(_,[],[]).
notToUseColors(V,[First|AllDiff],NewNot) :- member(V,First), onlyNumbers(First,Nums), append(Nums,NotToUse,NewNot), notToUseColors(V,AllDiff,NotToUse),!. % barvy jsou cisla
notToUseColors(V,[First|AllDiff],NotToUse) :- \+ member(V,First), notToUseColors(V,AllDiff,NotToUse),!. % v tomto constarintu vrchol neni, kontrola dalsiho

% chromNumber(+Coloring,-TotalChromaticIndex) :- pro obarveni Coloring spocte, kolik barev bylo pouzito
chromNumber(List,ChN) :- chromNumber(List,[],ChN).
chromNumber([],Nums,ChN) :- sort(Nums,Sorted), length(Sorted,ChN). % sort maze duplicity
chromNumber([_-N|Oth],Numbers,ChN) :- chromNumber(Oth,[N|Numbers],ChN). % obarveni je format vrchol-barva

% findColoring(+EdgesVetricesList,+Constraints,+Colors,-Coloring) :- zkusi obarvit barvami z ColorListu hrany a vrcholy tak, aby splnovaly constrainty
findColoring([],_,_,[]).
findColoring([CurrVE|OtherVE],AllDiff,ColorList,[CurrVE-Color|Sol]) :-
    notToUseColors(CurrVE,AllDiff,ForbiddenColors), removeList(ColorList,ForbiddenColors,Candidates), Candidates \= [], member(Color, Candidates), % jak ebarvy nepouzit, ty odecist od moznych barev, jednu vybrat
    replaceEverywhere(CurrVE,Color,AllDiff,NewAllDiff), allDifferentLists(AllDiff), findColoring(OtherVE,NewAllDiff,ColorList,Sol),!. % nahradit vrchol barvou v constraintech, zkontrolovat constrainty, obarvit dalsi vrchol/hranu

% colorWithNColors(+graph(V,E),+N,-Solution) :- pokusi se obarvit graf N barvami
colorWithNColors(graph(Vertices,Edges),N,Solution) :-
    allEdgesAndVertices(graph(Vertices,Edges),VerticesEdges), % spoji seznamy vrcholu a hran
    listNto1(N,ColorList), % vytvori list moznych barev
    vertexEdgesConstraint(graph(Vertices,Edges),L1), edgeVerticesConstraint(graph(Vertices,Edges),L2), % vytvori constrainty
    append(L1,L2,AllDiff), findColoring(VerticesEdges,AllDiff,ColorList,Solution),!.

colorWithNColors(graph(Vertices,Edges),N,Solution) :- % pokud se obarveni N barvami nepovedlo, zvysim pocet barev o jedna
    NewN is N + 1, colorWithNColors(graph(Vertices,Edges),NewN,Solution).

% solver(+graph(V,E),-TotalChromaticIndex,-Coloring) :- pro zadany graf nalezne totalni chormaticke cislo a prislusne obarveni
solver(graph(Vertices,Edges),ChromaticNumber,Solution) :-
    maxDegree(Vertices,Edges,MaxDeg), N is MaxDeg + 1, % χ″(G) ≥ Δ(G) + 1
    colorWithNColors(graph(Vertices,Edges),N,Solution),
    chromNumber(Solution,ChromaticNumber).

% tests

% "Complete graph on 3 vertices" (3)
test1 :- solver(graph([a,b,c],[e(a,b),e(b,c),e(c,a)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Cycle of length 5" (4)
test2 :- solver(graph([a,b,c,d,e],[e(a,b),e(b,c),e(c,d),e(d,e),e(e,a)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Petersen graph" (4)
test3 :- solver(graph([a,b,c,d,e,f,g,h,i,j],[e(e,a),e(a,b),e(b,c),e(c,d),e(d,e),e(e,j),e(a,f),e(b,g),e(c,h),e(d,i),e(j,g),e(j,h),e(f,i),e(f,h),e(g,i)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Star graph on 5 vertices" (5)
test4 :- solver(graph([a,b,c,d,e],[e(a,e),e(b,e),e(c,e),e(d,e)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Pentagram" (4)
test5 :- solver(graph([a,b,c,d,e],[e(a,c),e(a,d),e(b,e),e(b,d),e(c,e)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Star graph on 10 vertices" (10)
test6 :- solver(graph([a,b,c,d,e,f,g,h,i,j],[e(a,e),e(b,e),e(c,e),e(d,e),e(f,e),e(g,e),e(h,e),e(i,e),e(j,e)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Chvatal graph" (5)
test7 :- solver(graph([a,b,c,d,e,f,g,h,i,j,k,l],[e(a,b),e(b,d),e(c,d),e(c,a),e(a,f),e(e,b),e(a,k),e(c,l),e(c,i),e(d,j),e(h,b),e(g,d),e(l,h),e(e,i),e(f,j),e(g,k)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Complete graph on 7 vertices" (7)
test8 :- solver(graph([a,b,c,d,e,f,g],[e(a,b),e(a,c),e(a,d),e(a,e),e(a,f),e(a,g),e(b,c),e(b,d),e(b,e),e(b,f),e(b,g),e(c,d),e(c,e),e(c,f),e(c,g),e(d,e),e(d,f),e(d,g),e(e,f),e(e,g),e(f,g)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Cycle of length 14" (4)
test9 :- solver(graph([a,b,c,d,e,f,g,h,i,j,k,l,m,n],[e(a,b),e(b,c),e(c,d),e(d,e),e(e,f),e(f,g),e(g,h),e(h,i),e(i,j),e(j,k),e(k,l),e(l,m),e(m,n),e(n,a)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Complete bipartite graph on 4+4 vertices" (6)
test10 :- solver(graph([a,b,c,d,e,f,g,h],[e(a,e),e(a,f),e(a,g),e(a,h),e(b,e),e(b,f),e(b,g),e(b,h),e(c,e),e(c,f),e(c,g),e(c,h),e(d,e),e(d,f),e(d,g),e(d,h)]),ChN,Sol),write(ChN),write(" "),write(Sol).

% "Hypercube of dimension 3" (4)
test11 :- solver(graph([a,b,c,d,e,f,g,h],[e(e,h),e(e,f),e(e,a),e(h,d),e(h,g),e(f,g),e(g,c),e(f,b),e(d,c),e(b,c),e(a,b),e(a,d)]),ChN,Sol),write(ChN),write(" "),write(Sol).
