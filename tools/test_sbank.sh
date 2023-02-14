set -e

PREFIX=$(python -c "import sys; print(sys.prefix)")
PYTHON="python -m coverage run --append"

# Run sbank to generate XML and HDF banks
${PYTHON} ${PREFIX}/bin/sbank --approximant IMRPhenomD --aligned-spin --mass1-min 15.0 --mass1-max 25.0 --spin1-min 0.0 --spin1-max 0.5 --match-min 0.97 --flow 20.0 --noise-model aLIGOZeroDetHighPower --output-filename BBH-IMRPhenomD-aLIGOZeroDetHighPower.xml --convergence-threshold 25

${PYTHON} ${PREFIX}/bin/sbank --approximant IMRPhenomD --aligned-spin --mass1-min 15.0 --mass1-max 25.0 --spin1-min 0.0 --spin1-max 0.5 --match-min 0.97 --flow 20.0 --noise-model aLIGOZeroDetHighPower --output-filename BBH-IMRPhenomD-aLIGOZeroDetHighPower.hdf --convergence-threshold 25

XML_SIZE=`ligolw_print BBH-IMRPhenomD-aLIGOZeroDetHighPower.xml -t sngl_inspiral | wc -l`
HDF_SIZE=`h5ls BBH-IMRPhenomD-aLIGOZeroDetHighPower.hdf | grep "spin1z" | awk '{print $3}'`
HDF_SIZE="${HDF_SIZE:1:3}"

if ((XML_SIZE < 140 || XML_SIZE > 160)); then
  echo "The XML bank is not the expected size " ${XML_SIZE}
  exit 1
fi

if ((HDF_SIZE < 140 || HDF_SIZE > 160)); then
  echo "The HDF bank is not the expected size " ${HDF_SIZE}
  exit 1
fi

## Example to test tidal stochastic bank generation:
# sbank --approximant IMRPhenomD_NRTidalv2 --aligned-spin --mass1-min 1.5 \
#     --mass1-max 1.6 --spin1-min -0.04 --spin1-max 0.04 --mass2-min 1.4 --mass2-max 1.5 \
#     --match-min 0.9 --flow 30.0 --noise-model aLIGOZeroDetHighPower \
#     --output-filename NSBH-IMRPhenomD_NRTidal2-aLIGOZeroDetHighPower.hdf --verbose \
#     --spin2-min -0.04 --spin2-max 0.04 --use-tidal --lambda1-only --lambda1-min 2000 \
#     --lambda2-max 4000 --use-tidal --convergence-threshold 10
