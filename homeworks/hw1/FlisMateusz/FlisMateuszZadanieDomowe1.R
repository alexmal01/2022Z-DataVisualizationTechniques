install.packages("PogromcyDanych")
library(PogromcyDanych)
library(dplyr)
library(stringr)
colnames(auta2012)
dim(auta2012)
head(auta2012[,-ncol(auta2012)])
sum(is.na(auta2012))
View(auta2012)

## 1. Z kt�rego rocznika jest najwi�cej aut i ile ich jest?

auta2012 %>% 
  group_by(Rok.produkcji) %>%
  summarise(n = n()) %>% 
  top_n(1,n)

## Odp: Z roku 2011 jest ich najwi�cej. Dok�adnie 17418.


## 2. Kt�ra marka samochodu wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku?

auta2012 %>% 
  filter(Rok.produkcji==2011) %>% 
  group_by(Marka) %>% 
  summarise(n = n()) %>% 
  top_n(1,n)

## Odp: Skoda wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku.


## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?

auta2012 %>% 
  filter(Rodzaj.paliwa == "olej napedowy (diesel)" & Rok.produkcji > 2004 & Rok.produkcji < 2012) %>% 
  count()
  

## Odp: Takich samochod�w jest 59534.


## 4. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, kt�ra marka jest �rednio najdro�sza?

auta2012 %>% 
  filter(Rodzaj.paliwa == "olej napedowy (diesel)" & Rok.produkcji == 2011) %>%
  group_by(Marka) %>% 
  summarise(SredniKoszt = mean(Cena.w.PLN)) %>% 
  top_n(1,SredniKoszt)

## Odp: Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, Porsche jest �rednio najdro�sze.


## 5. Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, kt�ry model jest �rednio najta�szy?

auta2012 %>% 
  filter(Marka=="Skoda" & Rok.produkcji == 2011) %>%
  group_by(Model) %>% 
  summarise(SredniKoszt = mean(Cena.w.PLN)) %>% 
  top_n(1,-SredniKoszt)

## Odp: Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, model Fabia jest najta�szy.


## 6. Kt�ra skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut,
##    kt�rych stosunek ceny w PLN do KM wynosi ponad 600?

auta2012 %>% 
  mutate(StosunekCenyDoKM = (Cena.w.PLN/KM)) %>% 
  filter(StosunekCenyDoKM > 600 & Liczba.drzwi=="2/3") %>% 
  group_by(Skrzynia.biegow) %>% 
  summarise(n = n()) %>% 
  top_n(1,n)
  
## Odp: Automatyczna skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut,
##    kt�rych stosunek ceny w PLN do KM wynosi ponad 600


## 7. Spo�r�d aut marki Skoda, kt�ry model ma najmniejsz� r�nic� �rednich cen 
##    mi�dzy samochodami z silnikiem benzynowym, a diesel?

baza1 <- auta2012 %>% 
  filter(Marka=="Skoda" & Rodzaj.paliwa=="olej napedowy (diesel)") %>% 
  group_by(Model) %>% 
  summarise(SredniaCenaOlej = mean(Cena.w.PLN))

baza2 <- auta2012 %>% 
  filter(Marka=="Skoda" & (Rodzaj.paliwa=="benzyna" | Rodzaj.paliwa=="benzyna+LPG")) %>% 
  group_by(Model) %>% 
  summarise(SredniaCenaBenzyna = mean(Cena.w.PLN))

inner_join(baza1,baza2,by=c("Model")) %>% 
  filter(Model != "inny") %>% 
  mutate(Roznica = abs(SredniaCenaBenzyna - SredniaCenaOlej)) %>% 
  top_n(1,-Roznica)

## Odp:  Spo�r�d aut marki Skoda, model Favorit ma najmniejsz� r�nic� �rednich cen 
##    mi�dzy samochodami z silnikiem benzynowym, a diesel. Ro�nica jest r�wna 132z�.


## 8. Znajd� najrzadziej i najcz�ciej wyst�puj�ce wyposa�enie/a dodatkowe 
##    samochod�w marki Lamborghini


lambo <- auta2012 %>% 
  filter(Marka=="Lamborghini") 

wyposazenia <- unique(str_split(lambo$Wyposazenie.dodatkowe,pattern = ", ",simplify = FALSE))



## Odp: 


## 9. Por�wnaj �redni� i median� mocy KM mi�dzy grupami modeli A, S i RS 
##    samochod�w marki Audi

auta2012 %>% 
  filter(Marka == "Audi") %>% 
  mutate(ModelNew = case_when(str_detect(Model,"RS") ~ "RS",
                              str_detect(Model,"S") ~ "S",
                              str_detect(Model,"A") ~ "A",
                              TRUE ~ "Other")) %>% 
  select(Marka,ModelNew,Model,KM) %>%
  filter(ModelNew!="Other") %>% 
  group_by(ModelNew) %>% 
  summarise(SredniaKM = mean(KM,na.rm=TRUE), MedianaKM = median(KM,na.rm=TRUE))
  
  


## Odp: �rednia i mediana mocy KM: 
## Dla grupy A: �rednia wi�ksza od mediany,
## Dla grupy RS: �rednia wi�ksza od mediany,
## Dla grupy S: �rednia r�wna medianie.


## 10. Znajd� marki, kt�rych auta wyst�puj� w danych ponad 10000 razy.
##     Podaj najpopularniejszy kolor najpopularniejszego modelu dla ka�dej z tych marek.

auta2012 %>% 
  group_by(Marka) %>% 
  summarise(n = n()) %>% 
  filter(n > 10000) %>% 
  select(Marka)

auta2012 %>% 
  filter(Marka == "Audi" | Marka == "BMW" | Marka == "Ford" | Marka == "Mercedes-Benz" | Marka == "Opel" | Marka == "Renault" | Marka == "Volkswagen") %>% 
  group_by(Marka) %>% 
  count(Model,Kolor) %>% 
  slice(which.max(n))

## Odp: Marka - Model - kolor;
## Audi - A4 - czarny metaliczny;
## BMW - 320 - srebrny metaliczny;
## Ford - Focus - srebrny metaliczny;
## Mercedes-Benz - C 220 - srebrny metaliczny;
## Opel - Astra - srebrny metaliczny;
## Renault - Scenic - srebrny metaliczny;
## Volkswagen - Passat - srebrny metaliczny.