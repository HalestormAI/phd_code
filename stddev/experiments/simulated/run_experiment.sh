pushd ~

matlab -nodisplay -r "EXP_START=1;EXP_END=3;heightvar_against_error;exit"
matlab -nodisplay -r "EXP_START=4;EXP_END=6;heightvar_against_error;exit"
matlab -nodisplay -r "EXP_START=7;EXP_END=9;heightvar_against_error;exit"
matlab -nodisplay -r "EXP_START=10;EXP_END=11;heightvar_against_error;exit"

popd;
