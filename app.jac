import:py streamlit as st;
import:py from dotenv, load_dotenv;
import:py from PyPDF2, PdfReader;
import:py from langchain.text_splitter, CharacterTextSplitter;
import:py from langchain_openai, OpenAIEmbeddings;
import:py from langchain_community.vectorstores, FAISS;
import:py from langchain_community.embeddings, HuggingFaceEmbeddings;
import:py from langchain.memory, ConversationBufferMemory;
import:py from langchain.chains, ConversationalRetrievalChain;
import:py from langchain_community.chat_models, ChatOpenAI;
import:py from htmlTemplates, css, bot_template, user_template;


can get_pdf_text(files: list);

can get_junk_text(text: str);

can get_vector_store(text_chunks: any);

can get_conversation(vectorstore: any);

can handle_user_input(user_input: any, conversation:any);


can main(){
    load_dotenv();

    st.set_page_config(page_title="Chat with multiple PDFs", page_icon=":books:", layout="wide");

    st.write(css, unsafe_allow_html=True);

    if "conversation" not in st.session_state{
        st.session_state.conversation = None;
    }

    if "chat_history" not in st.session_state{
        st.session_state.chat_history = None;
    }

    st.title("Chat with multiple PDFs");
    user_question = st.text_input("Ask anything about your multiple PDFs");

    st.write(bot_template.replace("{{MSG}}", "Hello, I am a bot. How can I help you?"), unsafe_allow_html=True);

    if user_question{
        handle_user_input(user_question, st.session_state.conversation);
    }
        

    with st.sidebar{
        st.title("Your Documents");
        pdf_docs = st.file_uploader("Upload your PDF files here", accept_multiple_files=True);
   
        if st.button("Done"){
            with st.spinner("Processing your files..."){
                # get content of the pdf files 
                raw_text = get_pdf_text(pdf_docs);

                # get the text chunks
                chunks = get_junk_text(raw_text);

                # create a vector store
                # st.write(chunks)
                vectorstore = get_vector_store(chunks);

                # # create a conversation
                st.session_state.conversation = get_conversation(vectorstore);
            }
        }
    }
}

with entry{
    if __name__ == "__main__"{
        main();
    }
}