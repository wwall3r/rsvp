import { LogIn } from "lucide";
import replaceElement from "lucide/dist/esm/replaceElement.js";

// this is the same as the typical lucide config ...
const config = {
    icons: {
        LogIn,
        // any other icons you want to use here
    },
    // ... except that this is required as we are skipping the function which 
    // sets its default value
    nameAttr: "data-icon",
};

class LucideIcon extends HTMLElement {
    connectedCallback() {
        replaceElement(this, config);
    }
}

customElements.define("lucide-icon", LucideIcon);
// use as <lucide-icon data-icon="log-in" {...anyAttrs}></lucide-icon>
