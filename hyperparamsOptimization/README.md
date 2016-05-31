




| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |


[I'm an inline-style link](https://www.google.com)


<ul>
<li><a href="https://github.com/JasperSnoek/spearmint">Spearmint</a> (Python)</li>
<li><a href="http://rmcantin.bitbucket.org/html/">BayesOpt</a> (C++ with Python and Matlab/Octave interfaces)</li>
<li><a href="http://hyperopt.github.io/hyperopt/">hyperopt</a> (Python)</li>
<li><a href="http://www.cs.ubc.ca/labs/beta/Projects/SMAC/">SMAC</a> (Java)</li>
<li><a href="https://github.com/ziyuw/rembo">REMBO</a> (Matlab)</li>
<li><a href="https://github.com/Yelp/MOE">MOE</a> (C++/Python)</li>
</ul>




teste


"Gaussian process Bayesian optimization, optimizing the hyperparameters of a squared-exponential covariance, and proposed the Tree Parzen Algorithm." [Snoeak et. al.]





* Most packages seem to use Bayesian Optimization / Gaussian Processes approach to model the relationship f between parameter choices and the performance of the whole system
Most use  (who)
* Kanter et. al seem to an exception and use Gaussian Copula Process (GCP) instead.





These are the notable packages that we know of

The performance of machine learning systems depends on its parameter settings. Therefore it is , especially if there’s more than one or two hyperparameters

(b) autotune a machine learning pathway to extract the most value out of the synthesized features


# Comments on Kanter et. al
* According to Snoek et al, the approach depends on the type of *function*. They describe the Bayesian optimization process for continuous functions:

"For continuous functions, Bayesian optimization typically works by assuming the unknown function was sampled from a Gaussian process and maintains a posterior distribution for this function as observations are made or, in our case, as the results of running learning algorithm experiments with different hyperparameters are observed. To pick the hyperparameters of the next experiment, one can optimize the ()..."

* Currently the Deep Synthesis Machine *refines itself to continuous*, especially  int-type data. This contrasts with other packages like hyperopt, where the package has functon for recommending the right *algo*.



# References

Kanter, Max; Veeramachaneni, Kalyan. "Deep Feature Synthesis: Towards Automating Data Science Endeavors"
Jasper Snoek, Hugo Larochelle, Ryan P. Adams. "Practical Bayesian Optimization of Machine Learning Algorithms"



