pkg load signal

%%%%%%%%%%%%%%%%%%%%%%%%% Vypocet parametrov %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function retval = parameters(file)
  
  [y, fs] = audioread(file);
  y = y - mean(y);
  
  Fs = 16000; 
  N = 512; 
  wlen = 25e-3 * Fs; 
  wshift = 10e-3*Fs; 
  woverlap = wlen - wshift; 
  win = hamming(wlen);
  f = (0:(N/2-1)) / N * Fs;
  t = (0:(1 + floor((length(y) - wlen) / wshift) - 1))* wshift/Fs;
  X = specgram(y, N, Fs, win, woverlap);
  
  %vykresli dany spektogram
  %imagesc(t,f,10*log(abs(X).^2));  
  
  P = 10*log(abs(X).^2);
  [nr, nc] = size(P);
  class = class(P);
  
  Nc = 16;
  B = 256/Nc;
  
  set (gca (), 'fontsize', 20, "ydir", "normal"); xlabel ("Time"); ylabel ("Frequency"); colormap(jet);
  
  result = zeros(16, nc, class);
  mat = zeros(16, nc, class);

  for i = 1:16
    for j = 1:16
      mat = mat + P((i-1)*B+j, :);
   endfor
   result(i,:) = mat(1, :);
   mat = zeros(16, nc, class);
  endfor
  
  retval = result;
  return;
  
endfunction
  
%%%%%%%%%%%%%%%%%%%%%%%% FUNKCIA NA VYPOCET SKORE %%%%%%%%%%%%%%%%%%%%%%%%
 
function funkcia6 = score(q, s, Nq, colums)
  
  Mq = mean(q);
  Ms = mean(s);
  columsq = 1;
  Nc = 16;
  funkcia5 = 0;
  funkcia6 = 0;
  counter = 0;
  
  for j = 1:Nq
    funkcia1 = @(i)((q(i,columsq) - Mq(columsq)).*(s(i,colums)-Ms(colums))); % Vypocet hodnotu nad zlomkovou ciarou
    funkcia11 = sum(funkcia1([1:Nc])); % Sumacia vrchnej hodnoty
  
    funkcia2 = @(i)(q(i,columsq) - Mq(columsq)).^2; %Vypocet spodnej casti query
    funkcia22 = sum(funkcia2([1:Nc])); % sumacia
    funkcia222 = sqrt(funkcia22); % odmocnenie
  
    funkcia3 = @(i)(s(i,colums) - Ms(colums)).^2; %Vypocet spodnej casti sentence
    funkcia33 = sum(funkcia3([1:Nc])); % sumacia
    funkcia333 = sqrt(funkcia33); % odmocnenie
  
    funkcia4 = funkcia11 ./ (funkcia333.*funkcia222);
    funkcia5 = funkcia5 + funkcia4;
    
    colums++;
    columsq++;
  endfor
  colums = 0;  
  %funkcia6 = funkcia5./counter;
  funkcia6 = funkcia5/Nq;
  
endfunction

%%%%%%%%%%%%%%%%%%%%%%%%% SAMOTNY VYPOCET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Nacitanie jednotlivych slov a viet
result1 = parameters('../sentences/sx371.wav');
result2 = parameters('../queries/q1.wav');
result3 = parameters('../queries/q2.wav');

[nr1, nc1] = size(result1);
[nr2, nc2] = size(result2);
[nr3, nc3] = size(result3);

timeline = nc1 - nc2;
time = [0:5:timeline]/100;
[tr, tc] = size(time);

query1 = zeros(1, tc, class(result2));
query2 = zeros(1, tc, class(result3));

colums_q = 1;
cmp = 1;
while colums_q <= (nc1-nc2)
  query1(1,cmp) = score(result2, result1, nc2, colums_q);
  colums_q = colums_q + 5;
  cmp++;
endwhile

colums_q = 1;
cmp = 1;
while colums_q <= (nc1-nc3)
  query2(1,cmp) = score(result3, result1, nc3, colums_q);
  colums_q = colums_q + 5;
  cmp++;
endwhile

%% LOAD SENTENCE FOR GRAPH
function y_sentence = dlzka_vety(file)
   [y, fs] = audioread(file);
   y_sentence = y - mean(y);
   return;
endfunction
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRAFY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(3,1,1);
query1(query1 == 0) = nan;
query2(query2 == 0) = nan;
plot(time, query1, 'r')
hold on
plot(time, query2, 'g');
legend ("Query1", "Query2");
title ("sx371.wav", "fontsize", 15)
xlabel ("time", "fontsize", 15);
ylabel ("score", "fontsize", 15);
set(gca,'fontsize',15);grid on

hold on
subplot(3,1,2);
% nacitanie vety pre ziskanie dlzky vety kvoli grafu
y_sentence = dlzka_vety('../sentences/sx371.wav');
time = [0:length(y_sentence)-1]/16000;
plot(time,y_sentence);
title ("Graph of signal", "fontsize", 15)
xlabel ("time", "fontsize", 15)
ylabel ("signal", "fontsize", 15)
set(gca,'fontsize',15);grid on

hold on
subplot(3,1,3);
mt = [1:columns(result1)]/100;
mq = [1:rows(result1)];
imagesc(mt,mq,result1);
xlabel ("time", "fontsize", 15); ylabel ("features", "fontsize", 15);
set(gca,'fontsize',15);grid on







