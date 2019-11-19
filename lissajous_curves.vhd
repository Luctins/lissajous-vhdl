----
-- @author: Douglas Martins, Lucas M. Mendes, Matheus R. Willemann
-- Projeto Final ELD - gerador de Figuras de Lissajous

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


--- TODO: ver lookup table funções Sin e cos ou implementação polinomial

entity gerador_figuras is

  port(
    x_out, y_out  : out std_logic_vector(15 downto 0) := X"0000" ; -- inteiros de 16 bits
    var_in : in std_logic_vector(15 downto 0);
    next_bt : in std_logic;
    clk: in std_logic;
);
end gerador_figuras;

-- Este sistema utiliza um sistema numérico de ponto fixo, com número de casas
-- decimais dado por dec_offset
architecture arq of gerador_figuras is

  -- Constantes e declarações de tipos
  constant precision : integer := 32;
  constant dec_offset : integer := 100; -- Três casas decimais de precisão
  constant pi : integer := 3141; -- pi with decimal offset
  subtype int is signed(precision downto 0);
  -- Variáveis
  variable x_ampl : int := 5*dec_offset;  --TODO: ajustar estes valores
  variable y_ampl : int := 5*dec_offset;
  variable alpha  : int := 2*dec_offset;
  variable beta   : int := 4*dec_offset;
  variable delta  : int := 0;
  variable t      : int := 0;
  --variable angle : unsigned(9 downto 0) := 0;

  --TODO: fazer process para ajustar valores das variaveis
  -- Funções

  -- Aproximação de Taylor de seno, com boa precisão entre 0 e 90º
  pure function sin_0_pi2 (a : integer) return integer is
    constant 3_t : int := 6*dec_offset;
    constant 5_t : int := 120*dec_offset;
    variable x : integer := (a*dec_offset)/360; -- angle to radians
  begin
    return x - (x*x*x) / 3_t + (x*x*x*x*x) / (5_t);
  end function;
  pure function sin (angle : integer) return integer is
    variable mod_ang : integer := 0;
    variable quadrant : integer := 1;
    variable angl = angle mod 360;
begin
  mod_ang := ang mod 90; -- this uses the simmetries in a sine curve for better precision
  quadrant := ang / 90;

  case quadrant is
    when 0 =>
      return sin_0_pi2(ang);
    when 1 =>
      return sin_0_pi2(signed(ang)-180);
    when 2 =>
      return -1*sin_0_pi2(ang);
    when others =>
      return -1*sin_0_pi2(signed(ang)-180);;
  end case;
end function;

begin
  increment_t: process(clk)
    if rising_edge(clk) then
      t := (t + 1);
    end if;
  end process;


  x_out <= x_ampl * sin(((t*alpha + delta)*360)/(2*pi));
  y_out <= y_ampl * sin(((t*beta)*360)/(2*pi));
end arq;
