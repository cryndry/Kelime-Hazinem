import 'package:flutter/material.dart';

abstract final class MySvgs {
  static String colorToHex(Color color) {
    String result = "#";
    for (int value in [color.red, color.green, color.blue, color.alpha]) {
      result += value.toRadixString(16).padLeft(2, "0");
    }
    return result;
  }

  static String strokeChange(String svgInitial, Color strokeColor) {
    String hex = colorToHex(strokeColor);
    return svgInitial.replaceAll(RegExp(r'(stroke="[0-9a-z.#]*")'), 'stroke="$hex"');
  }

  static const String willLearn = """
<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
<path d="M21.9486 18.4V4M12.2663 23.344L13.4766 18.4H6.42058C6.04479 18.4 5.67417 18.3133 5.33806 18.1466C5.00195 17.98 4.70958 17.7381 4.48411 17.44C4.25865 17.1419 4.10627 16.7959 4.03904 16.4293C3.97182 16.0627 3.9916 15.6857 4.09682 15.328L6.91679 5.728C7.06344 5.22948 7.36921 4.79157 7.7882 4.48C8.20719 4.16843 8.7168 4 9.24054 4H25.5794C26.2214 4 26.8371 4.25286 27.291 4.70294C27.745 5.15303 28 5.76348 28 6.4V16C28 16.6365 27.745 17.247 27.291 17.6971C26.8371 18.1471 26.2214 18.4 25.5794 18.4H22.239C21.7887 18.4002 21.3474 18.525 20.9647 18.7603C20.5819 18.9956 20.273 19.3321 20.0726 19.732L15.8971 28C15.3264 27.993 14.7646 27.8582 14.2538 27.6057C13.743 27.3532 13.2963 26.9895 12.9472 26.5418C12.598 26.094 12.3554 25.5739 12.2375 25.0202C12.1196 24.4664 12.1294 23.8934 12.2663 23.344Z"
    stroke="white" fill="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const favorites = """
<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
<path d="M16 4L19.708 11.8991L28 13.1735L22 19.3186L23.416 28L16 23.8991L8.584 28L10 19.3186L4 13.1735L12.292 11.8991L16 4Z" 
    stroke="white" fill="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const learned = """
<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
<path d="M10.0514 13.6V28M19.7337 8.656L18.5234 13.6H25.5794C25.9552 13.6 26.3258 13.6867 26.6619 13.8534C26.998 14.02 27.2904 14.2619 27.5159 14.56C27.7414 14.8581 27.8937 15.2041 27.961 15.5707C28.0282 15.9373 28.0084 16.3143 27.9032 16.672L25.0832 26.272C24.9366 26.7705 24.6308 27.2084 24.2118 27.52C23.7928 27.8316 23.2832 28 22.7595 28H6.42057C5.7786 28 5.16292 27.7471 4.70897 27.2971C4.25502 26.847 4 26.2365 4 25.6V16C4 15.3635 4.25502 14.753 4.70897 14.3029C5.16292 13.8529 5.7786 13.6 6.42057 13.6H9.76097C10.2113 13.5998 10.6526 13.475 11.0353 13.2397C11.4181 13.0044 11.727 12.6679 11.9274 12.268L16.1029 4C16.6736 4.00701 17.2354 4.1418 17.7462 4.39432C18.257 4.64683 18.7037 5.01053 19.0528 5.45824C19.402 5.90596 19.6446 6.42611 19.7625 6.97984C19.8804 7.53357 19.8706 8.10656 19.7337 8.656Z"
    stroke="white" fill="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const memorized = """
<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
<path d="M16.3776 4C17.7424 4.04837 18.7013 4.5241 19.2543 5.42719C19.9664 4.95204 20.8039 4.78469 21.7668 4.92503C22.8471 5.14529 23.5389 5.64745 23.8424 6.43151C25.2187 6.11742 26.3355 6.38172 27.1924 7.22439C27.5225 7.65403 27.6439 8.11211 27.5565 8.59873C27.0949 10.4947 26.6215 12.3888 26.1364 14.2811C26.7498 16.2956 27.3445 18.313 27.9207 20.3334C28.3157 22.8044 27.2354 24.8571 24.6799 26.4915C22.0793 27.9402 19.1905 28.3454 16.0135 27.7072C14.7989 27.4165 13.7065 26.976 12.7363 26.3858C10.0756 24.3313 7.44174 22.261 4.83462 20.1748C3.70981 19.189 3.7219 18.2111 4.87103 17.2412C5.94683 16.6572 7.0878 16.5868 8.29388 17.0297C8.54623 17.1599 8.7768 17.3097 8.98574 17.479C9.67621 18.1563 10.4651 18.7642 11.3526 19.3027C13.3477 20.0139 15.0348 19.7408 16.4141 18.4833C17.422 17.1196 17.1428 15.9127 15.5766 14.8625C13.9219 14.0824 12.3197 14.1353 10.77 15.0211C10.4088 15.4066 9.97188 15.7413 9.45911 16.0254C7.77878 16.6041 6.48006 16.3133 5.56288 15.1532C5.32285 14.6254 5.32285 14.0968 5.56288 13.5675C7.89625 10.911 11.2099 9.88024 15.5037 10.4752C16.2026 10.6324 16.8823 10.8086 17.5429 11.0038C16.4292 9.73086 15.3247 8.45342 14.2293 7.17154C13.3731 5.97835 13.7008 5.00046 15.2124 4.23787C15.5972 4.12422 15.9855 4.04493 16.3776 4Z" 
    stroke="white" fill="currentColor" stroke-width="1.5"/>
</svg>
""";
  static const add2List = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M14.6667 16H4M21.3333 8H4M21.3333 24H4M24 12V20M28 16H20" 
    stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const backArrow = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M25.3332 16.0001H6.6665M6.6665 16.0001L15.9998 25.3334M6.6665 16.0001L15.9998 6.66675"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const clearText = """
<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M23.6 16.4L16.4 23.6M16.4 16.4L23.6 23.6M32 20C32 26.6274 26.6274 32 20 32C13.3726 32 8 26.6274 8 20C8 13.3726 13.3726 8 20 8C26.6274 8 32 13.3726 32 20Z"
    stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
</svg>
""";
  static const cloud = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M5.33338 19.8654C4.34277 18.8533 3.59547 17.6291 3.14809 16.2854C2.70071 14.9417 2.56499 13.5138 2.75119 12.1098C2.9374 10.7059 3.44065 9.36278 4.22284 8.18215C5.00502 7.00153 6.04562 6.0144 7.26582 5.29551C8.48602 4.57662 9.85381 4.14485 11.2656 4.03288C12.6774 3.92091 14.0961 4.13169 15.4144 4.64925C16.7327 5.16682 17.9159 5.97759 18.8744 7.02016C19.8329 8.06273 20.5415 9.30975 20.9467 10.6668H23.3334C24.6207 10.6666 25.874 11.0805 26.908 11.8474C27.9421 12.6142 28.7021 13.6933 29.0757 14.9252C29.4494 16.1571 29.417 17.4766 28.9832 18.6886C28.5493 19.9007 27.7372 20.9411 26.6667 21.6561M16 16.0001V28.0001M16 28.0001L10.6667 22.6668M16 28.0001L21.3334 22.6668"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const delete = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M4 8.00008H28M25.3333 8.00008V26.6667C25.3333 28.0001 24 29.3334 22.6667 29.3334H9.33333C8 29.3334 6.66667 28.0001 6.66667 26.6667V8.00008M10.6667 8.00008V5.33341C10.6667 4.00008 12 2.66675 13.3333 2.66675H18.6667C20 2.66675 21.3333 4.00008 21.3333 5.33341V8.00008"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
</svg>
""";
  static const edit = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M14.7349 6.53024H6.38553C5.75285 6.53024 5.14608 6.78157 4.69871 7.22894C4.25133 7.67631 4 8.28308 4 8.91577V25.6145C4 26.2472 4.25133 26.8539 4.69871 27.3013C5.14608 27.7487 5.75285 28 6.38553 28H23.0842C23.7169 28 24.3237 27.7487 24.7711 27.3013C25.2184 26.8539 25.4698 26.2472 25.4698 25.6145V17.2651M23.6806 4.74109C24.1551 4.26658 24.7987 4 25.4698 4C26.1408 4 26.7844 4.26658 27.2589 4.74109C27.7334 5.2156 28 5.85918 28 6.53024C28 7.2013 27.7334 7.84487 27.2589 8.31938L15.9276 19.6506L11.1566 20.8434L12.3494 16.0724L23.6806 4.74109Z"
    stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const littleDownArrow = """
<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M4 6L8 10L12 6" stroke="black" stroke-linecap="round" stroke-linejoin="round" />
</svg>
""";
  static const plus = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16 4V28M4 16H28"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const refresh = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<g opacity="0.8">
  <path d="M28 4V11.2M28 11.2H20M28 11.2L24 7.96C22.2741 6.57065 20.1384 5.6604 17.8505 5.33902C15.5626 5.01765 13.2203 5.29889 11.106 6.14883C8.99175 6.99876 7.19588 8.38107 5.93501 10.129C4.67413 11.877 4.00211 13.916 4 16M4 28V20.8M4 20.8H12M4 20.8L8 24.04C9.72593 25.4294 11.8616 26.3396 14.1495 26.661C16.4374 26.9823 18.7797 26.7011 20.894 25.8512C23.0082 25.0012 24.8041 23.6189 26.065 21.871C27.3259 20.123 27.9979 18.084 28 16"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>
""";
  static const save = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M29.3332 14.7732V15.9999C29.3315 18.8751 28.4005 21.6728 26.679 23.9757C24.9574 26.2785 22.5376 27.9632 19.7803 28.7784C17.0231 29.5937 14.0762 29.4958 11.3791 28.4993C8.68208 27.5029 6.37938 25.6614 4.81445 23.2493C3.24953 20.8373 2.50623 17.984 2.69541 15.115C2.88459 12.246 3.99611 9.515 5.86421 7.32933C7.73231 5.14366 10.2569 3.62041 13.0614 2.98676C15.866 2.35311 18.8002 2.64302 21.4265 3.81323M29.3332 5.33323L15.9998 18.6799L11.9998 14.6799"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const search = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M28 28L22.2 22.2M25.3333 14.6667C25.3333 20.5577 20.5577 25.3333 14.6667 25.3333C8.77563 25.3333 4 20.5577 4 14.6667C4 8.77563 8.77563 4 14.6667 4C20.5577 4 25.3333 8.77563 25.3333 14.6667Z"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const settings = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16.2933 2.66675H15.7067C14.9994 2.66675 14.3211 2.9477 13.8211 3.4478C13.321 3.94789 13.04 4.62617 13.04 5.33341V5.57341C13.0395 6.04105 12.9161 6.50033 12.6821 6.9052C12.448 7.31006 12.1117 7.64626 11.7067 7.88008L11.1333 8.21341C10.728 8.44746 10.2681 8.57068 9.8 8.57068C9.3319 8.57068 8.87205 8.44746 8.46667 8.21341L8.26667 8.10675C7.65476 7.75376 6.92779 7.65801 6.24534 7.84049C5.56289 8.02298 4.98074 8.4688 4.62667 9.08008L4.33334 9.58675C3.98035 10.1987 3.88459 10.9256 4.06708 11.6081C4.24957 12.2905 4.69538 12.8727 5.30667 13.2267L5.50667 13.3601C5.9097 13.5928 6.24483 13.9269 6.47874 14.3292C6.71265 14.7315 6.83719 15.188 6.84 15.6534V16.3334C6.84187 16.8033 6.71954 17.2654 6.48539 17.6728C6.25125 18.0802 5.91361 18.4185 5.50667 18.6534L5.30667 18.7734C4.69538 19.1275 4.24957 19.7096 4.06708 20.3921C3.88459 21.0745 3.98035 21.8015 4.33334 22.4134L4.62667 22.9201C4.98074 23.5314 5.56289 23.9772 6.24534 24.1597C6.92779 24.3422 7.65476 24.2464 8.26667 23.8934L8.46667 23.7867C8.87205 23.5527 9.3319 23.4295 9.8 23.4295C10.2681 23.4295 10.728 23.5527 11.1333 23.7867L11.7067 24.1201C12.1117 24.3539 12.448 24.6901 12.6821 25.095C12.9161 25.4998 13.0395 25.9591 13.04 26.4267V26.6667C13.04 27.374 13.321 28.0523 13.8211 28.5524C14.3211 29.0525 14.9994 29.3334 15.7067 29.3334H16.2933C17.0006 29.3334 17.6789 29.0525 18.179 28.5524C18.6791 28.0523 18.96 27.374 18.96 26.6667V26.4267C18.9605 25.9591 19.0839 25.4998 19.318 25.095C19.552 24.6901 19.8884 24.3539 20.2933 24.1201L20.8667 23.7867C21.2721 23.5527 21.7319 23.4295 22.2 23.4295C22.6681 23.4295 23.128 23.5527 23.5333 23.7867L23.7333 23.8934C24.3452 24.2464 25.0722 24.3422 25.7547 24.1597C26.4371 23.9772 27.0193 23.5314 27.3733 22.9201L27.6667 22.4001C28.0197 21.7882 28.1154 21.0612 27.9329 20.3787C27.7504 19.6963 27.3046 19.1141 26.6933 18.7601L26.4933 18.6534C26.0864 18.4185 25.7488 18.0802 25.5146 17.6728C25.2805 17.2654 25.1581 16.8033 25.16 16.3334V15.6667C25.1581 15.1969 25.2805 14.7348 25.5146 14.3274C25.7488 13.92 26.0864 13.5817 26.4933 13.3467L26.6933 13.2267C27.3046 12.8727 27.7504 12.2905 27.9329 11.6081C28.1154 10.9256 28.0197 10.1987 27.6667 9.58675L27.3733 9.08008C27.0193 8.4688 26.4371 8.02298 25.7547 7.84049C25.0722 7.65801 24.3452 7.75376 23.7333 8.10675L23.5333 8.21341C23.128 8.44746 22.6681 8.57068 22.2 8.57068C21.7319 8.57068 21.2721 8.44746 20.8667 8.21341L20.2933 7.88008C19.8884 7.64626 19.552 7.31006 19.318 6.9052C19.0839 6.50033 18.9605 6.04105 18.96 5.57341V5.33341C18.96 4.62617 18.6791 3.94789 18.179 3.4478C17.6789 2.9477 17.0006 2.66675 16.2933 2.66675Z"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16 20.0001C18.2091 20.0001 20 18.2092 20 16.0001C20 13.7909 18.2091 12.0001 16 12.0001C13.7909 12.0001 12 13.7909 12 16.0001C12 18.2092 13.7909 20.0001 16 20.0001Z"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
""";
  static const tip = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M9.10345 20.1233H22.8965M8.92893 19.9541C7.53041 18.5652 6.578 16.7956 6.19215 14.869C5.8063 12.9425 6.00433 10.9456 6.76121 9.13088C7.51809 7.31614 8.79981 5.76505 10.4443 4.67376C12.0888 3.58247 14.0222 3 16 3C17.9778 3 19.9112 3.58247 21.5557 4.67376C23.2002 5.76505 24.4819 7.31614 25.2388 9.13088C25.9957 10.9456 26.1937 12.9425 25.8078 14.869C25.422 16.7956 24.4696 18.5652 23.0711 19.9541M11.5172 23.5479H20.4828M17.3793 26.8258C17.3793 27.4743 16.7618 28 16 28C15.2382 28 14.6207 27.4743 14.6207 26.8258M14.6207 26.6301H17.3793"
    stroke="white" stroke-width="2" stroke-linecap="round" />
</svg>
""";
  static const undo = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12.0002 18.6666L5.3335 11.9999M5.3335 11.9999L12.0002 5.33325M5.3335 11.9999H19.3335C20.2965 11.9999 21.2501 12.1896 22.1398 12.5581C23.0296 12.9267 23.838 13.4668 24.5189 14.1478C25.1999 14.8288 25.7401 15.6372 26.1086 16.5269C26.4771 17.4166 26.6668 18.3702 26.6668 19.3333C26.6668 20.2963 26.4771 21.2499 26.1086 22.1396C25.7401 23.0293 25.1999 23.8377 24.5189 24.5187C23.838 25.1997 23.0296 25.7398 22.1398 26.1084C21.2501 26.4769 20.2965 26.6666 19.3335 26.6666H14.6668"
    stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
</svg>
""";
}
