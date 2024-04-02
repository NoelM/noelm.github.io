+++
author = "Noël"
title = "Construction d'une antenne long-fil EFHW multibande"
date = "2024-04-02"
draft = false
+++

Habitant en ville, il n'est pas simple de faire de la HF. Alors la majeure partie du temps
j'opère en HF en portable avec mon Yaesu FT-817 et un mat SOTA beams de 7m. Quant à l'antenne,
j'utilise une long fil de 10 mètres accordée sur la bande des 20 mètres. Plus précisément, c'est
une antenne _End-Fed Half-Wave (EFHW)_, que l'on traduirait probablement comme :
_antenne demie-onde alimentée par terminaison_.

Elle possède quatre avantages :
* une géométrie simple avec un seul élément radiant, donc facile à mettre en place n'importe où ;
* légère et compacte, elle s'emporte dans une petite poche de sac à dos ;
* très efficace, généralement j'arrive à me rapprocher de 1 à 1.2 SWR ;
* et enfin, elle s'accorde avec [un petit tuner 49:1 pour le QRP](https://qrpguys.com/end-fed-half-wave-sota-antenna-tuner), qui lui aussi est très léger.

Cependant cette configuration est monobande alors que le tuner en supporte 5 de 40 à 15 mètres.
C'est ainsi que j'ai entrepris la construction d'une antenne multibande.

## Théorie

Pour commencer, on trouvera une excellente description ce qu'est une antenne EFHW dans l'article de Steve Yates AA5TB[^1].
Elles correspondent à des antennes doublet demi-onde, où l'on alimenterait que d'un seul côté au lieu d'avoir une
alimentation centrale. Cette configuration donne à l'anntenne une très forte impédance de 1800 à 5000 ohms [^1].

### Transformateur d'impédance

Pour ce faire il est nécessaire d'avoir un tranformateur d'impédance d'un facteur 100:1 à 50:1. La transformation
d'impédance entre l'impédance d'entrée \(Z_E\) et celle de sortie \(Z_S\) est le carré du rapport du nombre de spires
respectivement, \(N_E\) en entrée et \(N_S\) en sortie, alors le rapport d'impédance est le suivant :
$$
\frac{Z_E}{Z_S} = \left ( \frac{N_E}{N_S} \right)^2 \,.
$$

Pour arriver à cela, on part de la définition d'un transformateur entre une tension \(U_E\) d'entrée et \(U_S\) de sortie :
$$
\frac{U_E}{N_E} = \frac{U_S}{N_S} \,.
$$

Si on l'exprime sous forme de puissance \(P\), la tension s'écrit

$$
U = \sqrt{ \frac{P}{Z} } \,,
$$

sachant la loi d'Ohm \(U = Z \cdot I\).

Ainsi on peut exprimer le rapport des tensions comme :
$$
\frac{1}{N_E} \sqrt{\frac{P_E}{Z_E}} = \frac{1}{N_S} \sqrt{\frac{P_S}{Z_S}}
$$

Si notre transformateur est parfait, les puissances d'entrée et de sorties sont égales \(P_E = P_S\) et l'on retrouve
le rapport des impédances ci-dessus. CQFD !

En conclusion pour des rapports d'impédances entre 100:1 et 50:1, il nous faudra des transformateurs entre 10:1 et 7:1
(les racines carrées des rapports d'impédances).

### Longueur des brins rayonnants

Aussi, comme son nom l'indique la longueur du brin radiant est de \(\lambda /2\). A cela près qu'il faut prendre en compte
le facteur \(K\) lié au rapport du diamètre du conducteur \(d\) de la longueur d'onde \(\lambda / 2d \)[^2].

Ce facteur s'exprime de la façon suivante :
$$
K = \frac{0.225706}{\ln \left ( \frac{\lambda}{2d} \right ) - 0.429451} \,,
$$
comme exprimé par Steve Steams, K6OIK.

Dans mon cas, pour une section 0.5 mm² le facteur se situe entre 0.97 et 0.98. La longueur des brins s'exprime de la manière
suivante :
$$
l (m) = K \frac{150}{f (MHz)} \,.
$$

| Band | Center (MHz) | λ/2 (m) | K λ/2 (m) | Sections (m)
| -----|--------------|---------|-----------|--------------
| 15m  | 21.2         |7.08     | 6.86      | 6.86
| 17m  | 18.118       |8.28     | 8.03      | 1.17
| 20m  | 14.15        |10.60    | 10.28     | 2.25
| 30m  | 10.125       |14.81    | 14.37     | 4.09
| 40m  | 7.1          |21.13    | 20.49     | 6.12


[^1]: [The End Fed Half Wave Antenna, _Steve Yates AA5TB_](https://www.aa5tb.com/efha.html)
[^2]: Amateur Radio Handbook, ARRL, Edition 100, Sec. 21.1.7