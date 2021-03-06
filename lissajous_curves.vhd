---------------------------------------------------------------------
-- @author: Douglas Martins, Lucas M. Mendes, Matheus R. Willemann --
-- Projeto Final ELD - gerador de Figuras de Lissajous             --
-- @date: qui nov 28 15:09:34 -03 2019
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity lissajous_curves is
  generic(
    dec_offset : integer := 100; -- offset decimal global para todos os valores
                                 -- de ponto fixo
    precision : integer := 8; -- numero de bits de precisao da saida
    pi : integer := 314; -- pi com offset decimal
    x_ampl  : integer  := (1 sll (precision - 1));-- (2^7), amplitude de x
    y_ampl  : integer := (1 sll (precision - 1 )); -- (2^7), amplitude de y
    global_clock : integer := 5000000; -- valor do clock global
    delta_update : integer := 40; -- taxa de atualização delta 40 = 0.4/s
    screen_update : integer := 100000 -- taxa de atualização da forma de onda
    );
  port(
    x_out, y_out  : out std_logic_vector((precision - 1) downto 0) := X"00" ; -- inteiros
                                                                              --com "precision" bits
    clk: in std_logic
    );
end lissajous_curves;

-- Este sistema utiliza um sistema numérico de ponto fixo, com número de casas
-- decimais dado por dec_offset

architecture arq of lissajous_curves is

  -- tipos --------------------------
  subtype int is integer range 131071 downto -131071; -- 131071 = 2 ^ 17 - 1

  -- Variáveis e sinais ---------------------------

  -- parâmetros da figura
  shared variable t       : integer range (2*pi+1) downto 0 := 0;

  signal alpha   : int := 2 * dec_offset;
	signal beta    : int := 6 * dec_offset;
  signal delta   : int := 0;

	shared variable x_tmp : int := 0;
	shared variable y_tmp : int := 0;

  shared variable a,b : int := 0;

  -- Funções -----------------------------------------

  -- Multiplicação, levando em conta o offset decimal
  pure function mult (x: integer; y : integer) return integer is
  begin
    return (x*y)/dec_offset;
  end function;

  -- Divisao,  levando em conta o offset decimal
  pure function div (x: integer; y : integer) return integer is
  begin
    return (x*dec_offset)/y;
  end function;

  -- Seno  - implementado por meio de uma tabela de valores, com precisão de
  -- 0.01 radiano
  function sin_0_pi2 ( rad : int ) return int is
  begin
    case rad is
      when  0     => return  0 ;
      when  1     => return  0 ;
      when  2     => return  1 ;
      when  3     => return  2 ;
      when  4     => return  3 ;
      when  5     => return  4 ;
      when  6     => return  5 ;
      when  7     => return  6 ;
      when  8     => return  7 ;
      when  9     => return  8 ;
      when  10    => return  9 ;
      when  11    => return  10 ;
      when  12    => return  11 ;
      when  13    => return  12 ;
      when  14    => return  13 ;
      when  15    => return  14 ;
      when  16    => return  15 ;
      when  17    => return  16 ;
      when  18    => return  17 ;
      when  19    => return  18 ;
      when  20    => return  19 ;
      when  21    => return  20 ;
      when  22    => return  21 ;
      when  23    => return  22 ;
      when  24    => return  23 ;
      when  25    => return  24 ;
      when  26    => return  25 ;
      when  27    => return  26 ;
      when  28    => return  27 ;
      when  29    => return  28 ;
      when  30    => return  29 ;
      when  31    => return  30 ;
      when  32    => return  31 ;
      when  33    => return  32 ;
      when  34    => return  33 ;
      when  35    => return  34 ;
      when  36    => return  35 ;
      when  37    => return  36 ;
      when  38    => return  37 ;
      when  39    => return  38 ;
      when  40    => return  38 ;
      when  41    => return  39 ;
      when  42    => return  40 ;
      when  43    => return  41 ;
      when  44    => return  42 ;
      when  45    => return  43 ;
      when  46    => return  44 ;
      when  47    => return  45 ;
      when  48    => return  46 ;
      when  49    => return  47 ;
      when  50    => return  47 ;
      when  51    => return  48 ;
      when  52    => return  49 ;
      when  53    => return  50 ;
      when  54    => return  51 ;
      when  55    => return  52 ;
      when  56    => return  53 ;
      when  57    => return  53 ;
      when  58    => return  54 ;
      when  59    => return  55 ;
      when  60    => return  56 ;
      when  61    => return  57 ;
      when  62    => return  58 ;
      when  63    => return  58 ;
      when  64    => return  59 ;
      when  65    => return  60 ;
      when  66    => return  61 ;
      when  67    => return  62 ;
      when  68    => return  62 ;
      when  69    => return  63 ;
      when  70    => return  64 ;
      when  71    => return  65 ;
      when  72    => return  65 ;
      when  73    => return  66 ;
      when  74    => return  67 ;
      when  75    => return  68 ;
      when  76    => return  68 ;
      when  77    => return  69 ;
      when  78    => return  70 ;
      when  79    => return  71 ;
      when  80    => return  71 ;
      when  81    => return  72 ;
      when  82    => return  73 ;
      when  83    => return  73 ;
      when  84    => return  74 ;
      when  85    => return  75 ;
      when  86    => return  75 ;
      when  87    => return  76 ;
      when  88    => return  77 ;
      when  89    => return  77 ;
      when  90    => return  78 ;
      when  91    => return  78 ;
      when  92    => return  79 ;
      when  93    => return  80 ;
      when  94    => return  80 ;
      when  95    => return  81 ;
      when  96    => return  81 ;
      when  97    => return  82 ;
      when  98    => return  83 ;
      when  99    => return  83 ;
      when  100   => return  84 ;
      when  101   => return  84 ;
      when  102   => return  85 ;
      when  103   => return  85 ;
      when  104   => return  86 ;
      when  105   => return  86 ;
      when  106   => return  87 ;
      when  107   => return  87 ;
      when  108   => return  88 ;
      when  109   => return  88 ;
      when  110   => return  89 ;
      when  111   => return  89 ;
      when  112   => return  90 ;
      when  113   => return  90 ;
      when  114   => return  90 ;
      when  115   => return  91 ;
      when  116   => return  91 ;
      when  117   => return  92 ;
      when  118   => return  92 ;
      when  119   => return  92 ;
      when  120   => return  93 ;
      when  121   => return  93 ;
      when  122   => return  93 ;
      when  123   => return  94 ;
      when  124   => return  94 ;
      when  125   => return  94 ;
      when  126   => return  95 ;
      when  127   => return  95 ;
      when  128   => return  95 ;
      when  129   => return  96 ;
      when  130   => return  96 ;
      when  131   => return  96 ;
      when  132   => return  96 ;
      when  133   => return  97 ;
      when  134   => return  97 ;
      when  135   => return  97 ;
      when  136   => return  97 ;
      when  137   => return  97 ;
      when  138   => return  98 ;
      when  139   => return  98 ;
      when  140   => return  98 ;
      when  141   => return  98 ;
      when  142   => return  98 ;
      when  143   => return  99 ;
      when  144   => return  99 ;
      when  145   => return  99 ;
      when  146   => return  99 ;
      when  147   => return  99 ;
      when  148   => return  99 ;
      when  149   => return  99 ;
      when  150   => return  99 ;
      when  151   => return  99 ;
      when  152   => return  99 ;
      when  153   => return  99 ;
      when  154   => return  99 ;
      when  155   => return  99 ;
      when  156   => return  99 ;
      when others => return 100 ;
    end case;
  end function;

  function sin (x : int) return int is
    variable t : int;
    variable m : int;
	begin
		m := x mod (2*pi); -- x entre 0 e 2*pi
		t := x mod (pi/2); -- x entre 0 e pi/2

    -- Isto mapeia chamadas de função de
    -- forma a utilizar as simetrias da
    -- função seno e apenas implementar o 1o quadrante
    if m < pi/2 then
			return sin_0_pi2(t);

    elsif m >= pi/2 and m < pi then
			return sin_0_pi2((pi/2) - t);

    elsif m >= pi and m < 471 then
			return -1*sin_0_pi2(t);

    else
			return -1*sin_0_pi2((pi/2) - t);

		end if;
	end function;

begin
  increment_t: process(clk)
    variable count : integer range 0 to global_clock/screen_update; -- divide clock por screen_update
  begin

    if rising_edge(clk) then
      count := count + 1;

      if count = global_clock/screen_update then

        t := (t + 1);
        t := t mod (2*pi); -- reduz t entre 0 e 2*pi

        a := (mult(t,alpha) + delta);
        b := mult(t,beta);

        x_tmp := x_ampl * (1*dec_offset + sin(a)); -- 1 + sin(t*alpha + delta)
        x_tmp := x_tmp/dec_offset; -- remove offset decimal

        y_tmp := y_ampl * (1*dec_offset + sin(b)); --1  + sin(t*beta)
        y_tmp := y_tmp/dec_offset; -- remove offset decimal

        x_out <= std_logic_vector(to_signed(x_tmp,precision));
        y_out <= std_logic_vector(to_signed(y_tmp,precision));

        count := 0;

      end if;

    end if;

  end process;

  update_param: process(clk,alpha,beta,delta)
    -- como o clock é de 50 Mhz e queremos uma taxa igual a delta_update dividimos
    -- o clock principal por delta update
    variable count : integer range global_clock/delta_update  downto 0 := 0;
    variable updn : std_logic := '1'; -- contando pra cima ou pra baixo

  begin
    if falling_edge(clk) then
      if count = global_clock/delta_update then

        if updn = '0' then
          delta <= delta - 1;

        else
          delta <= delta + 1;

        end if;

        if delta >= pi then
          updn := '0';

        elsif delta <= 0 then
          updn := '1';

        end if;

        count := 0;
      else
        count := count + 1;
      end if;

    end if;
  end process;
end arq;
