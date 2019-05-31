#!/bin/sh
# This script was generated using Makeself 2.3.0

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1211792870"
MD5="59b4f7e08ea12f51ba829f1cc8d25c0c"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="Extracting potd-q54"
script="echo"
scriptargs="The initial files can be found in the newly created directory: potd-q54"
licensetxt=""
helpheader=''
targetdir="potd-q54"
filesizes="6031"
keep="y"
nooverwrite="n"
quiet="n"
nodiskspace="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt"
    while true
    do
      MS_Printf "Please type y to accept, n otherwise: "
      read yn
      if test x"$yn" = xn; then
        keep=n
	eval $finish; exit 1
        break;
      elif test x"$yn" = xy; then
        break;
      fi
    done
  fi
}

MS_diskspace()
{
	(
	if test -d /usr/xpg4/bin; then
		PATH=/usr/xpg4/bin:$PATH
	fi
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.3.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory
                        directory path can be either absolute or relative
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 532 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    else

		tar $1f - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 36 KB
	echo Compression: gzip
	echo Date of packaging: Wed Apr 11 15:42:10 CDT 2018
	echo Built with Makeself version 2.3.0 on darwin17
	echo Build command was: "./makeself/makeself.sh \\
    \"--notemp\" \\
    \"../../questions/potd3_054_adjMatrix/potd-q54\" \\
    \"../../questions/potd3_054_adjMatrix/clientFilesQuestion/potd-q54.sh\" \\
    \"Extracting potd-q54\" \\
    \"echo\" \\
    \"The initial files can be found in the newly created directory: potd-q54\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"y" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"potd-q54\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=36
	echo OLDSKIP=533
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 532 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 532 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 532 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 36 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace $tmpdir`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 36; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (36 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
� "s�Z�<pŕ�Zɒן�I���1@��vW�k�U,�b[90���HZg���r��%�R/��@�Q���0�˝��T	rdp!]�+��@I�R#�IT&q�{��gwvv%����vi��u�����ׯ{�5]n�y�����<Ikhj���)��������Qe���GUe5�WssbQ�Q$��'̀hmm3w��J?#���������K�t�k�����
�6����Z�J{m-����̓�[�{K��o�n_�r�]_����!�����HA�A1��#���Ųu�n@�����u��bӖmH�>*{7{֭�w��=��v~�=v~����~KS����!��b���2&��%��r�k�e�����5��y�6k��!~U��BE�@E��È��&��(:��թ�����/��,��G��6~-(J'8��
嶬�w������1��j� ��?a�/��Ǽ������Ò.�_����R/n۱��-+���t�h�������1��o�����-<����Z�s���6�j|A�n�tm�X����2L��m��((���Z���Fh��x������|^h��&\;-.i4�'&���H����:�Ơ'�l""U4*�����$��p�җ���� {��c����,�d�����_ᨨ0�������k������
K��o�������_
H`�r�ķł��ηJ�������:�*I�E�|����}\����> �e;iu^!��s:��	�d~�&~�mlx�Y7�+�|�?�d�B��l��!�ķ��#��u�y��s�>J�/E�oZ��烒����lF���߷��}{6NK��,E���WdtY�#]�@�����U|	�zc��w��m���!>�{��M�1A����P�lm����5U��=# �����4�k��#dЦ����tcH����q"t�L�w���ˇ���_�>���j`�7������܄ӿ���b�3�9.^ p)<cE�����<NxDѵe�p���l��h�t �]��]9�c0����#r�R��F3�ۻ�����4\��[����(F�XktZ~,���e��P�����'vH�����FJ�(_��#J�),�����o�&�o\�0�衛�i���r��k:X
��ł|A����r���͔_��Y>�Cl��N2�|���nl���ՙ�OÖ][2틌ci��i0ڛ�K�Š_����bX�L˯T���dэkH΀3��2~Ku��ߍ�~�L�1~�:X���ܠ7:���.44jc`7�W椏ޔ棟+���^	�H�!=�nD��*�^�q�����^Km����I�� �b<[��\�NG���W��|1��Bxl�h����ڼ�^V#�{�����'5g����뗝X�J�E�Տ9���t�K2�[�T�T�C��L��T��x֭+w���V�_�����w��R��.FB�-L����v����N>�C>�C>��\������s��d�s�����z��J��TF�z+)�ބE�y��t&��O�L�g�Jǒ�Yg�Yݸ������d���S�;5��Nl!)��$��4U�(��?_�������-�B�������_(�&F��Ť�Q��=lR��g�����o��n�S�I��A�tv���O��y��z�!}y�a�;�$��$�5���� 'c�N�%u92�>�+��=�Gt�5$�;����c��SiEx�B��
c�4@���=�� *m�z5�Gݷ�t�8,�j�>�{������_g=����uԩ�ِ ��5(�@}��k=�At�v�)?C�)ͧT7�ҨZ��V��В�����2
A\����D5*睏��n��Y?��8��u���Vo@⑓@7�#�U+o:>�b4*à��&��3Щ1��Z @�L�.@g'��J���Ώ~���w$sZ�j��������H�Cf�Qs;�Q�`�a�G��i����9��i���(9���:�T
?TJ����N����c��RX�(Īԉ��z�5I��M<B�許����>PZ���I�#| m��4����	�r���֙��ܧß�ψ�6Gf�ڏ3���d��S�C��|XXb��O0�&=}�����L���:��r3	4y�Ϲ~�/s���K0Q��v�Qo '��cQ1Q'd���������߃����R�}qjj��3�,����Z-�,�7��T$�_$�_��B�P��2s����N�au9e�9��F���D�1uQAC�ĉ�r��s��$G�H����ޡ2H��]�Sgo��`%\�$�KzzQ�3Y�S�ķ��� ��6{Iһ�R�u�i]��uк0���gr��4�����t�7��$�i,s*% t=�%�%���Fы�Kv�@/σڔ� N&0^= �v�等�`%s��
���b]-�&���j�m=��������#Pp�8���񋤷gHrd�$�G!QW�`k��O��2XZ�CYJ��E�%4:n�:n0���SC�n<�#���K1�wb�"s�k�>9�Ћ�|w��@B<�́O�#r[�bj>��t1���I��D?j��(����_? �	��Ĩ39��Q��Kw.ك@�O{�<Ct=TB��BBD�C��lJ&P��abډ>��`���r���	� 〳���&�i�Y��7"<^DN_��q\󔖣 �']|2vt����7���c���_2�$�)��2���2�>��J�]�r6�@FB�@J�n
0�%j�SA�T����;~�&��m^�?��¹��e�:��B�&��62�Te�Dk6ZD�Qz�� ��׭��d�nG}��lDJ����7c CC�t���qjzG鐠E5)�c��$�ǲn�c�9�ɓ�8TH����5�:����(�
Ѥ~)3	(!�F�m}�&ʞ�RY�"��X@�jB@Ց4��C��!�>�u��+y����ӑ]J}-5IZHLn/�R�J���L��Db��T�Ѵ z}�fm����� �*4��`)/9{{�tam�a�a�z.e�ICO�F'	ug��0-Tz]�I1�QL�ޣQW>D;M�!��IҨ|ܤ�2O���y\&4?9��x�#�[��, L�㴫9ݿ��F���i�OA������������(�����&:���G�Gq�)x�f�e����[�M�4z?������&ȃo�Gi�t����5ٱ0�J�"��UpO�N�m�p�ߢ��Wu��`��Y���8g2���^�q�0��N}�'���yq^���Qt.��>oB����a%QEZ�Y%I
�U������a�<SZR6=/k�fL�j%�*�ճ�6U8:UH�L�F�*����d�,ꬂ�$��2z��BV|J2�9�.v��X�tT�=N�o����d�*�iȐ�&��(���.�1v���ø������ ��S�_��0�z��?%��U���5���o����"��$~���$��ϒ��$VI��ϑ��$�$��$����#��ޛAf�Ω�?����_��[1�6���l�5�bnsf4�����0�澋�S���\q�"	?�=�������1�n��e�1��y1�?��sdڠ��@i'���e�ۄ�}f��V��̠y�G��F��z��G�q���Dt ��� q���a~���B��C��V�s�0�{�LX�H�] ��j��s��1]YH"���.���\��<a�,�ы��Q��2q<g�p�?U|[$���O9^��E�(_&u�%�,y�PL�d��k�*M�@�Lv$��W�ع�*���>�����2�Cֳsa��K�/���q�YH��9ο���-�J���	�����8S?��|�4��+[L�~ȱ��5~mg�,5�.,.���e�rW�)~��J�����S$X��ز�t6�c}��3�t1K��<ۥ��_��-Y�
�����ֳ�K,��R��2��������r���c����������O!�!�!�!�!�!�!���cX��l�����-�����)W���
���{#�}��j�|0,5z�
�W�HM�������S,�h� g(�;;Ű���n�O>(�sq��\W��{K�w���J.~&́�t�8�wD�#n�y�!��E�O��@����+�P����	��/����ݓ�WQ%��,"��#K1*=�����;E#;�����yD��e�.q�]����k��*tX�o�m�|^�]ȩFDI�KӣRr�Aa�)�j[�������q;���T����K�Ǣ����H2�b�!p���:_(*��RM�$!��������v�~��[uPv�ۏˡ���쓅����T��VF��J����r��6,�A��r��#�:�;+Ed7͚����Y��G�V�}*���Ƹ?�2e� E%��V�,�����V�|1"���J,7}5���!� E�)�32��e����r���[�v_P���t`͙t��-k��&�) �!�"* o�i�$rE\��-!��5s�Q�<1Y;$7��5�q�ɏ�f�b�sϙj�ɮj�(x��,�
��O}]�iw�T��m��;]P��FZC&?/�	��;fn�hs����ȿ=g6Rrg6�-������D�W��	v���_�3>�NW|�l�V ��J�Q��jP�ރ�f�Z"�4�U�m�#^�Tu��i����&W�����7�N��J�����~Y�q^����(�p����(��}�aA�)�]�P�J��C:��`;����w�2a��.�G�k�F�2л���yF�����)�����i?�k��0�o��Ō?�_��o������{��k�������-��y%�^�5z���n��3���@7����0З�K���+�~�@){��YD�}��W��~
�d�>��3}2���ӌ�A>� ��_d�4�n����.Z�	����"���a�[�B&ϲ+/�l���/��|��ѻ�����R��N��>��g�y��WwP6��M�?�e�����3y��ź�N1Xk�k��2i������k�b;��������S���g	O��_���=k���ㇰ6b��O@�Ҕ�GML^�ޫ䫾�'��P8�Ѣ�Lx��������L�� ?k�_7�g�|]a&�� ��N�S�#�1����x�0S��x� �g��������?'�����:�?+|�v�
σ�wx��e���q�!|7����t���`��9H���C�g���s��u��/b�t�C���Mba����J��f7��{�+xA���彙_����N.�ٯ"yu0�u_����o�W����]��z�oԟ�]���D���9�G��~o��~=��ި�^��oJ�G�o�Y�ҹ��ެ�W꬟�l-Q��	x��!���aQ��P �����᜶�4�l��}�H��*���&>h��{��6��QrӘ-������VL]gD��?T]k��B?��鍥���r[L���T�-���%\w{B^���tA��� ��!зmW(�S�ixR�;��;=�VC�`��<����;l�V���K�4�<6;<]ß�VD������4�/^b=Ϲ�^b��q�g�5^N�`HAV\�.s1��n��	kl��%�����tJ��ۙ6[cm�ֻ�fk�fw��AʙP<�c�}�J)an�����r����p#�,���x7��~��Z���}�֭�+��REV��Y%�UZ8>��6�Rg��9�����>\��_���"�����s�w�z�������_����x�(�V��6խxw-��7��SױV�;T�{|�o����RTd�VP\�m��%�n~H���v5uo�~iB��͸�X8��\�˔i }�d���K�*2��������������������
��fNl x  