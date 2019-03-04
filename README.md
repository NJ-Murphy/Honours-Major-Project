# Honours-Major-Project

We study the Volume-Synchronized Probability of Informed Trading (VPIN) metric as proposed
by Easley et al. (2012)[1] to indicate order 
ow toxicity, a phenomenon in high-frequency trading
where market makers may be unaware they are providing liquidity at a loss due to the adverse
selection problem. We take you through the derivation of the original Probability of Informed
Trading (PIN) model introduced by Easley et al. (1996)[2] which forms the foundation of the
VPIN metric. The VPIN metric requires the classification of trading volume as being buyer- or
seller-initiated in order to calculate the Order Imbalance which provides an indication of order 
ow
toxicity within the market. We implement two approaches to classifying trading volume, the Bulk
Classification algorithm and the Lee-Ready algorithm, for stocks listed on the Johannesburg Stock
Exchange (JSE) and find no resemblance between the 
uctuations of VPIN over time resulting
from the two approaches.
Even though there is no agreement between the 
uctuations of VPIN for the two approaches, we
do however find a relation between the overall levels in VPIN for the two approaches for frequently
traded stocks with high market capitalisations. Furthermore, we find that infrequently traded
stocks with lower market capitalisations give much lower levels of VPIN for the Bulk Classification
approach than for Lee-Ready, resulting in poor performance of the Bulk Classification algorithm
for such stocks. We also find a relation between the change in the log-midquote around the same
time that VPIN was computed for each stock.
