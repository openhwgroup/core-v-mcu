# Hardware MAC Engine

If you are using the HWPE IPs for an academic publication, please cite the following paper:
```
@article{conti2018xne, 
  author={F. {Conti} and P. D. {Schiavone} and L. {Benini}}, 
  journal={IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems}, 
  title={XNOR Neural Engine: A Hardware Accelerator IP for 21.6-fJ/op Binary Neural Network Inference}, 
  year={2018}, 
  doi={10.1109/TCAD.2018.2857019}, 
  ISSN={0278-0070}, 
}
```

The Hardware MAC Engine is an example of a Hardware Processing Engine that can be coupled with the PULP/PULPissimo hardware.
It makes use of the interface IPs 'hwpe-ctrl' and 'hwpe-stream'.
It is not meant as a particularly efficient / powerful engine, but rather as a practical example of an HWPE.
It supports two modes:
 - in 'simple_mult' mode, it takes two 32bit fixed-point streams (vectors) a, b and computes
     d = a * b
   where '*' is the elementwise product.
 - in 'scalar_prod' mode, it takes three 32bit fixed-point streams (vectors) a, b, c and computes
     d = dot(a,b) + c
It can perform this iterations multiple times, on vectors separated by an iteration stride.
It performs the multiplication at full precision (64b) and the output is normalized with a configurable shift factor.
The four streams a, b, c, d are connected to four separate ports on the external memory interface (the simplest choice possible).
