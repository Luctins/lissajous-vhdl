----
-- @author: Douglas Martins, Lucas M. Mendes, Matheus R. Willemann
-- Projeto Final ELD - gerador de Figuras de Lissajous

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

--library ieee_proposed;
--use iee_proposed.fixed_pkg.all;

--- TODO: ver lookup table funções Sin e cos ou implementação polinomial


entity lissajous_curves is
  generic( precision : integer := 8) ;
  port(
    x_out, y_out  : out std_logic_vector((precision - 1) downto 0) := X"00" ; -- inteiros de 16 bits
    var_in : in std_logic_vector((precision - 1) downto 0);
    next_bt : in std_logic;
    clk: in std_logic
);
end lissajous_curves;

-- Este sistema utiliza um sistema numérico de ponto fixo, com número de casas
-- decimais dado por dec_offset

  --TODO: fazer process para ajustar valores das variaveis

architecture arq of lissajous_curves is

  -- tipos
  --constant precision : integer := 32;
  --subtype int is signed(31 downto 0);

  -- Constantes
  constant pi : integer := 314; -- pi with decimal offset
  constant dec_offset : integer := 100;

  -- Variáveis
  shared variable x_ampl  : integer := 127;
  shared variable y_ampl  : integer := 127;
  shared variable alpha   : integer := 2*dec_offset;
  shared variable beta    : integer := 4*dec_offset;
  shared variable delta   : integer := 0;
  shared variable t       : integer := 0;
	shared variable x_tmp   : std_logic_vector((precision - 1) downto 0);
	shared variable y_tmp   : std_logic_vector((precision - 1) downto 0);

-- Funções

  -- Multiplicação, levando em conta o offset decimal
  pure function mult (x: integer; y : integer) return integer is
  begin
    return (x*y)/dec_offset;
  end function;
  -- Divisao
  pure function div (x: integer; y : integer) return integer is
  begin
    return (x*dec_offset)/y;
  end function;

  -- Aproximação de Taylor de seno, com boa precisão entre 0 e 90º
--   pure function sin_0_pi2 (x : int) return int is
--     constant t_3 : int := to_signed(6,32)*dec_offset; -- 6*dec_offset;
--     constant t_5 : int := to_signed(120,32)*dec_offset;-- 120*dec_offset;
--   begin
--     return x - div( mult(x,mult(x,x)) , t_3) + div( mult(x,mult(x,mult(x,mult(x,x)))), t_5);
--   end function;

--   pure function sin (x : int := "0") return int is
--     variable quadVAR_DUMP(slope);rant :  int := "00";
--     --variable angl : integer := angle mod 360;
-- begin

--   quadrant := div(x, pi/2);
--   case quadrant is
--     when "00" =>
--       return sin_0_pi2(x);
--     when "01" =>
--       return sin_0_pi2(x-pi);
--     when "10" =>
--       return -1*sin_0_pi2(x);
--     when others =>
--       return -1*sin_0_pi2(x-pi);
--   end case;
-- end function;

  -- Seno implementado por tabela
  function sin_0_pi2 ( rad : integer ) return integer is
  begin
    case rad is
      when  0  => return  0 ;
      when  1  => return  0 ;
      when  2  => return  1 ;
      when  3  => return  2 ;
      when  4  => return  3 ;
      when  5  => return  4 ;
      when  6  => return  5 ;
      when  7  => return  6 ;
      when  8  => return  7 ;
      when  9  => return  8 ;
      when  10  => return  9 ;
      when  11  => return  10 ;
      when  12  => return  11 ;
      when  13  => return  12 ;
      when  14  => return  13 ;
      when  15  => return  14 ;
      when  16  => return  15 ;
      when  17  => return  16 ;
      when  18  => return  17 ;
      when  19  => return  18 ;
      when  20  => return  19 ;
      when  21  => return  20 ;
      when  22  => return  21 ;
      when  23  => return  22 ;
      when  24  => return  23 ;
      when  25  => return  24 ;
      when  26  => return  25 ;
      when  27  => return  26 ;
      when  28  => return  27 ;
      when  29  => return  28 ;
      when  30  => return  29 ;
      when  31  => return  30 ;
      when  32  => return  31 ;
      when  33  => return  32 ;
      when  34  => return  33 ;
      when  35  => return  34 ;
      when  36  => return  35 ;
      when  37  => return  36 ;
      when  38  => return  37 ;
      when  39  => return  38 ;
      when  40  => return  38 ;
      when  41  => return  39 ;
      when  42  => return  40 ;
      when  43  => return  41 ;
      when  44  => return  42 ;
      when  45  => return  43 ;
      when  46  => return  44 ;
      when  47  => return  45 ;
      when  48  => return  46 ;
      when  49  => return  47 ;
      when  50  => return  47 ;
      when  51  => return  48 ;
      when  52  => return  49 ;
      when  53  => return  50 ;
      when  54  => return  51 ;
      when  55  => return  52 ;
      when  56  => return  53 ;
      when  57  => return  53 ;
      when  58  => return  54 ;
      when  59  => return  55 ;
      when  60  => return  56 ;
      when  61  => return  57 ;
      when  62  => return  58 ;
      when  63  => return  58 ;
      when  64  => return  59 ;
      when  65  => return  60 ;
      when  66  => return  61 ;
      when  67  => return  62 ;
      when  68  => return  62 ;
      when  69  => return  63 ;
      when  70  => return  64 ;
      when  71  => return  65 ;
      when  72  => return  65 ;
      when  73  => return  66 ;
      when  74  => return  67 ;
      when  75  => return  68 ;
      when  76  => return  68 ;
      when  77  => return  69 ;
      when  78  => return  70 ;
      when  79  => return  71 ;
      when  80  => return  71 ;
      when  81  => return  72 ;
      when  82  => return  73 ;
      when  83  => return  73 ;
      when  84  => return  74 ;
      when  85  => return  75 ;
      when  86  => return  75 ;
      when  87  => return  76 ;
      when  88  => return  77 ;
      when  89  => return  77 ;
      when  90  => return  78 ;
      when  91  => return  78 ;
      when  92  => return  79 ;
      when  93  => return  80 ;
      when  94  => return  80 ;
      when  95  => return  81 ;
      when  96  => return  81 ;
      when  97  => return  82 ;
      when  98  => return  83 ;
      when  99  => return  83 ;
      when  100  => return  84 ;
      when  101  => return  84 ;
      when  102  => return  85 ;
      when  103  => return  85 ;
      when  104  => return  86 ;
      when  105  => return  86 ;
      when  106  => return  87 ;
      when  107  => return  87 ;
      when  108  => return  88 ;
      when  109  => return  88 ;
      when  110  => return  89 ;
      when  111  => return  89 ;
      when  112  => return  90 ;
      when  113  => return  90 ;
      when  114  => return  90 ;
      when  115  => return  91 ;
      when  116  => return  91 ;
      when  117  => return  92 ;
      when  118  => return  92 ;
      when  119  => return  92 ;
      when  120  => return  93 ;
      when  121  => return  93 ;
      when  122  => return  93 ;
      when  123  => return  94 ;
      when  124  => return  94 ;
      when  125  => return  94 ;
      when  126  => return  95 ;
      when  127  => return  95 ;
      when  128  => return  95 ;
      when  129  => return  96 ;
      when  130  => return  96 ;
      when  131  => return  96 ;
      when  132  => return  96 ;
      when  133  => return  97 ;
      when  134  => return  97 ;
      when  135  => return  97 ;
      when  136  => return  97 ;
      when  137  => return  97 ;
      when  138  => return  98 ;
      when  139  => return  98 ;
      when  140  => return  98 ;
      when  141  => return  98 ;
      when  142  => return  98 ;
      when  143  => return  99 ;
      when  144  => return  99 ;
      when  145  => return  99 ;
      when  146  => return  99 ;
      when  147  => return  99 ;
      when  148  => return  99 ;
      when  149  => return  99 ;
      when  150  => return  99 ;
      when  151  => return  99 ;
      when  152  => return  99 ;
      when  153  => return  99 ;
      when  154  => return  99 ;
      when  155  => return  99 ;
      when  156  => return  99 ;
		when others => return 0;
    end case;
  end function;

  function sin(x : integer ) return integer is
  begin
    case div(x, pi/2) is
      when 0 =>
        return sin_0_pi2(x);
      when 1 =>
        return sin_0_pi2(x-pi);
      when 2 =>
        return -1*sin_0_pi2(x);
      when others =>
        return -1*sin_0_pi2(x-pi); --depois checar se nao ocorre underflow aqui
    end case;
  end function;

begin
  increment_t: process(clk)
    variable  a,b : integer;
  begin
    if rising_edge(clk) then
      t := (t + 1);
      a := x_ampl * sin(t*alpha + delta);
      a := X_ampl/2 + a/dec_offset;
      b := y_ampl * sin(t*beta);
      b := y_ampl/2 + b / dec_offset;
		x_tmp := std_logic_vector(to_signed(a,precision));
		y_tmp := std_logic_vector(to_signed(b ,precision));
    end if;
  end process;

  x_out <= x_tmp;
  y_out <= y_tmp;
end arq;
